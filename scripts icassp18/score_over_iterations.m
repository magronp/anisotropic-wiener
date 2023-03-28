clear all; close all; clc;
test_or_dev = 'Dev';
set_setting;

% parameters
Kappa = [0.05 0.1 0.5 1 5 10]; Nk=length(Kappa);
Tau = [0.1 0.5 1 5 10]; Nt = length(Tau);
Kappa_lab = cell(1,Nk); Tau_lab = cell(1,Nt);
score = zeros(iter_bag+1,3,Nk,Nt);

% Load data
[sm,x,Sm,X] = get_data_DSD(dataset_path,test_or_dev,1,Fs,Nfft,Nw,hop);
[F,T,J] = size(Sm);
magapprox = abs(Sm)+eps;
vini = magapprox.^2;

% Initial phase and freq
muini = repmat(angle(X),[1 1 J]);
nu = zeros(F,T,J);
for j=1:J
    nu(:,:,j) = get_frequencies_qifft(vini(:,:,j))/Nfft;
end

% Phase influence
for nk = 1:Nk
    kappa = Kappa(nk);
    Kappa_lab{nk} =  num2str(kappa);
    for nt = 1:Nt
        clc; fprintf('Kappa %d / %d \n Tau %d / %d \n',nk,Nk,nt,Nt);
        tau = Tau(nt);
        Tau_lab{nt} =  num2str(tau);
        [~,~,~,scorebss] = bayesian_ag_estim(X,vini,muini,kappa,tau,hop,iter_bag,nu,1,sm,Nfft,Nw,wtype,0);
        score(:,:,nk,nt)=scorebss;
    end
end


save(strcat('outputs', 'score_over_iterations_bag.mat'),'score','Kappa_lab','Tau_lab');

% plot results
figure;
iter_bag = size(score,1)-1;
Nk = length(Kappa_lab);
for nk=1:Nk
    subplot(3,Nk,nk); plot(0:iter_bag, squeeze(score(:,1,nk,:)));
    subplot(3,Nk,Nk+nk); plot(0:iter_bag, squeeze(score(:,2,nk,:)));
    subplot(3,Nk,2*Nk+nk); plot(0:iter_bag, squeeze(score(:,3,nk,:)));
end
legend(Tau_lab);

