clc; clear all; close all;

% Parameters
Fs = 44100; Nw = 4096; Nfft = 4096; hop = Nw/4;
source_type = 'DSD100DEV';
Ndata = 20;
Nit = 100;

% NMF
Knmf = [20 20];
Nnmf = 100;

Delta = 10.^(-3:1:3);
Nd = length(Delta);

scenario = 'informed';
typeCW = 'CW';

switch typeCW
    case 'CW'
        kappa = 0;
    case 'CAW'
        switch scenario
            case 'oracle'
                kappa = 1;
            case 'informed'
                kappa = 0.8;
        end
end

% Score
SDR = zeros(Ndata,Nd); SIR = zeros(Ndata,Nd); SAR = zeros(Ndata,Nd);

for it=1:Ndata
    clc; fprintf('Iteration %d / %d \n',it,Ndata)
    % Gen Sources
    num_piece = it;
    gen_sources_time;
    gen_sources_TF_inst;
    smaux = [sm(1,:)+sm(2,:)+sm(3,:) ; sm(4,:)];
    Smaux(:,:,1) = Sm(:,:,1)+  Sm(:,:,2)+ Sm(:,:,3);
    Smaux(:,:,2) = Sm(:,:,4);
    clear sm; clear Sm;
    sm = smaux; Sm=Smaux;
    J=2;

    se = zeros(J,length(x));
    V=abs(Sm);

    % Variances (oracle or approx by nmf)
    switch scenario
        case 'oracle'
            V2 = V.^2;
            
        case 'informed'
            V2 = zeros(F,T,J);
            for j=1:J
                [waux,haux] = NMF(V(:,:,j),rand(F,Knmf(j)),rand(Knmf(j),T),Nnmf,1,0);
                V2(:,:,j) = (waux*haux).^2;
            end
    end
    
    % Wiener filtering (isotropic or Anisotropic)
    switch typeCW
        case 'CW'
            G = V2 ./ repmat(sum(V2,3)+eps,[1 1 J]);
            Xe = G .* repmat(X,[1 1 J]);
        case 'CAW'
            Sm_approx = sqrt(V2) .* exp(1i*repmat(angle(X),[1 1 J]));
            UN = detect_onset_frames(V,Fs,w,hop);
            Xe = phase_unwrap_anisotropic_gaussian(X,Sm_approx,UN,kappa*ones(F,T,J),hop);
    end
    m_post = Xe(:,:,1);
    mu = angle(Xe);
    
    
    % Consistent Wiener Filtering
    for d=1:Nd
        fprintf('Gamma %d / %d \n',d,Nd)
        delta = Delta(d);
        Xcw = consistent_anis_wiener(m_post,kappa,mu,V2,delta,Nfft,w,hop,Nit);
        
        se(1,:) = iSTFT(Xcw,Nfft,w,hop);
        se(2,:) = x'-se(1,:);

        % Score
        [sd,si,sa] = bss_eval_sources(se,sm);
        SDR(it,d) = mean(sd); SIR(it,d) = mean(si); SAR(it,d) = mean(sa);        
    end
    
end
clc;

% Average results
save(strcat('Consistent Anisotropic Wiener/inf_delta_',typeCW,'_',scenario,'.mat'),'SDR','SIR','SAR','Delta');
SDR(sum(isnan(SDR),2)>0,:)=[]; SIR(sum(isnan(SIR),2)>0,:)=[]; SAR(sum(isnan(SAR),2)>0,:)=[];


