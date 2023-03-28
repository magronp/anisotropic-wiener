clc; clear all; close all;

% Parameters
Fs = 44100; Nw = 4096; Nfft = 4096; hop = Nw/4;
source_type = 'DSD100';
Ndata = 50;
Nit = 100;

kappa = 0.8;
delta = 1;

% NMF
Knmf = [50 50];
Nnmf = 100;

scenario = 'informed';


% Score
SDR = zeros(Ndata,4,2); SIR = zeros(Ndata,4,2); SAR = zeros(Ndata,4,2);

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
    
    % Wiener filtering
    G = V2 ./ repmat(sum(V2,3)+eps,[1 1 J]);
    X_W = G .* repmat(X,[1 1 J]);
    
    % Anisotropic Wiener filtering
    Sm_approx = sqrt(V2) .* exp(1i*repmat(angle(X),[1 1 J]));
    UN = detect_onset_frames(V,Fs,w,hop);
    [X_AW,phiapprox] = phase_unwrap_anisotropic_gaussian(X,Sm_approx,UN,kappa*ones(F,T,J),hop);
   
    
    % Consistent Wiener Filtering
    X_CW = consistent_anis_wiener(X_W(:,:,1),0,angle(X_W),V2,delta,Nfft,w,hop,Nit);
    
    % Consistent Anisotropic Wiener Filtering
    X_CAW = consistent_anis_wiener(X_AW(:,:,1),kappa,phiapprox,V2,delta,Nfft,w,hop,Nit);
    
    
    % Synthesis
    se = zeros(4,J,length(x));
    for j=1:2
        se(1,j,:) = iSTFT(X_W(:,:,j),Nfft,w,hop);
        se(3,j,:) = iSTFT(X_AW(:,:,j),Nfft,w,hop);
    end
    se(2,1,:) = iSTFT(X_CW,Nfft,w,hop); se(2,2,:) = x-squeeze(se(2,1,:));
    se(4,1,:) = iSTFT(X_CAW,Nfft,w,hop); se(4,2,:) =x-squeeze(se(4,1,:));
    
    % Score
    for al=1:4
        [sd,si,sa] = bss_eval_sources(squeeze(se(al,:,:)),sm);
        SDR(it,al,:)=sd; SIR(it,al,:)=si; SAR(it,al,:)=sa;
    end

end

save(strcat('Consistent Anisotropic Wiener/benchmark_caw_',scenario,'.mat'),'SDR','SIR','SAR');
SDR([34 36 41],:,:) = []; SIR([34 36 41],:,:) = []; SAR([34 36 41],:,:) = [];

