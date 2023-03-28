% Learning the consistency weight for CAW

clc; clear all; close all;
test_or_dev = 'Dev';
scenario = 'oracle';
set_settings_caw;

% Consistency weight range
Delta = 10.^(-3:3);
Nd = length(Delta);

score = zeros(2,3,Nd,Nsongs);

% loop over the songs
for ind=1:Nsongs
    clc; fprintf('Iteration %d / %d \n',ind,Nsongs)
    
    % Load data
    num_piece = datavec(ind);
    [sm_aux,x,Sm_aux,X] = get_data_DSD(dataset_path,test_or_dev,num_piece,Fs,Nfft,Nw,hop);
    [F,T] = size(X);
    
    % Reshape the data so its music accompaniment + singing voice
    J=2;
    sm = [sm_aux(1,:)+sm_aux(2,:)+sm_aux(3,:) ; sm_aux(4,:)];
    Sm(:,:,1) = Sm_aux(:,:,1)+  Sm_aux(:,:,2)+ Sm_aux(:,:,3);
    Sm(:,:,2) = Sm_aux(:,:,4);
    clear sm_aux; clear Sm_aux;
    
    % Variances (oracle or informed scenario)
    V=abs(Sm);
    switch scenario
        case 'oracle'
            variances = V.^2;
        case 'informed'
            variances = zeros(F,T,J);
            for j=1:J
                [waux,haux] = NMF(V(:,:,j),rand(F,K),rand(K,T),iter_nmf,1,0);
                variances(:,:,j) = (waux*haux).^2;
            end
    end
    
    % Initial filterings (Wiener and Anisotropic Wiener)
    X_w = variances ./ (sum(variances,3)+eps) .* repmat(X,[1 1 J]);
    X_aw = anisotropic_wiener(X,variances,kappa_caw*ones(F,T,J),hop);
    
    % Loop over consistency weight
    for ind_d=1:Nd
        fprintf('Gamma %d / %d \n',ind_d,Nd)
        delta = Delta(ind_d);
        
        % Consistent Wiener filtering
        X_cw = caw(X_w,variances,0,delta,Nw,hop,wtype);
        
        % Consistent anisotropic Wiener filtering
        X_caw = caw(X_aw,variances,kappa_caw,delta,Nw,hop,wtype);
        
        % Synthesis
        s_cw = real(iSTFT(X_cw,Nfft,hop,Nw,wtype));
        s_caw = real(iSTFT(X_caw,Nfft,hop,Nw,wtype));

        % Score
        [sd,si,sa] = GetSDR(s_cw,sm);  score(1,:,ind_d,ind) = mean([sd si sa]);
        [sd,si,sa] = GetSDR(s_caw,sm); score(2,:,ind_d,ind) = mean([sd si sa]);
    end
    
end

% Record scores
save(strcat(metrics_path,'learning_caw_',scenario,'.mat'),'score','Delta');

% Plot the SDR
SDR = squeeze(mean(score(:,1,:,:),4));

figure;
semilogx(Delta,SDR(1,:),'b*-'); hold on; semilogx(Delta,SDR(2,:),'ro-');
title(scenario,'fontsize',16); xlabel('\delta','FontSize',16); ylabel('SDR (dB)','FontSize',16); 
ha=legend('Isotropic','Anisotropic'); set(ha,'FontSize',14);
