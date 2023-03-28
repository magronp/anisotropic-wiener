clear all; close all; clc;
test_or_dev = 'Dev';
set_settings_bag;

% Phase parameters
Kappa = [0 0.01 0.1 1]; Nk=length(Kappa);
Tau = [0 0.01 0.1 1 10]; Nt = length(Tau);
Kappa_lab = cell(1,Nk); Tau_lab = cell(1,Nt);

score = zeros(iter_bag+1,3,Nk,Nt,Nsongs);

for it=1:Nsongs

    num_piece = datavec(it);
    [sm,x,Sm,X] = get_data_DSD(dataset_path,test_or_dev,num_piece,Fs,Nfft,Nw,hop);
    [F,T,J] = size(Sm);
    magapprox = abs(Sm); upv=0;
    v = magapprox.^2+eps;

    % Initial phase and freq  -  Assume freq from true sources
    muini = repmat(angle(X),[1 1 J]);
    nu = zeros(F,T,J);
    for j=1:J
        nu(:,:,j) = get_frequencies_qifft(abs(Sm(:,:,j)))/Nfft;
    end

     % Inf phase - kappa=0
    clc; fprintf('Data %d / %d \n Kappa = tau = 0',it,Nsongs);
    [m_post,~,~,scorebss] = bayesian_ag_estim(X,v,muini,0,0,hop,iter_bag,nu,1,sm,Nfft,Nw,wtype,0);
    score(:,:,1,1,it) = scorebss;
    
     % Inf phase
    for nk = 2:Nk
        for nt = 1:Nt
            clc; fprintf('Data %d / %d \n Kappa %d / %d \n Tau %d / %d \n',it,Nsongs,nk,Nk,nt,Nt);
            kappa = Kappa(nk); tau = Tau(nt);
            [m_post,~,~,scorebss] = bayesian_ag_estim(X,v,muini,kappa,tau,hop,iter_bag,nu,1,sm,Nfft,Nw,wtype,0);
            score(:,:,nk,nt,it) = scorebss;
        end
    end

end

score(:,:,1,:,:) = repmat(score(:,:,1,1,:),[1 1 1 Nt 1]);
save(strcat(metrics_path,'learning_phase.mat'),'score','Kappa','Tau');

% Plot Results
sdr = squeeze(mean(score(:,:,1,:),4));
sir = squeeze(mean(score(:,:,2,:),4));
sar = squeeze(mean(score(:,:,3,:),4));

figure;
gcmap = colormap(autumn); gcmap = gcmap(end:-1:1,:); 
gcmap(:,2,:) = 1 - ((0:63)/64).^3;

colormap(gcmap);

subplot(1,3,1); imagesc(sdr); axis xy; title('SDR (dB)','fontsize',14); set(gca,'xticklabel',Tau,'yticklabel',Kappa); xlabel('\tau','fontsize',16); ylabel('\kappa','fontsize',16);
subplot(1,3,2); imagesc(sir); axis xy; title('SIR (dB)','fontsize',14); set(gca,'xticklabel',Tau,'yticklabel',[]); xlabel('\tau','fontsize',16); 
subplot(1,3,3); imagesc(sar); axis xy; title('SAR (dB)','fontsize',14); set(gca,'xticklabel',Tau,'yticklabel',[]); xlabel('\tau','fontsize',16); 