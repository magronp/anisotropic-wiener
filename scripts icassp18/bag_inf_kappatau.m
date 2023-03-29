clear all; close all; clc;
data_split = 'Dev';
global_setup;

% Anisotropy parameters
Kappa = [0 0.05 0.1 0.5 1 5 10]; Nk=length(Kappa);
Tau = [0 0.1 0.5 1 5 10]; Nt = length(Tau);

% Initialize score array
Nsongs = get_nsongs(data_split);
score = zeros(Nk,Nt,3,Nsongs);

% Loop over songs
for ind=1:Nsongs

    [sm,x,Sm,X] = get_data_DSD(dataset_path,data_split,ind,Fs,Nfft,Nw,hop,t_chunk);
    [F,T,J] = size(Sm);
    magapprox = abs(Sm); upv=0;
    v = magapprox.^2+eps;

    % Inindial phase and freq  -  Assume freq from true sources
    muini = repmat(angle(X),[1 1 J]);
    nu = zeros(F,T,J);
    for j=1:J
        nu(:,:,j) = get_frequencies_qifft(abs(Sm(:,:,j)))/Nfft;
    end

     % kappa=0 (no need to test all values for tau in this case)
    clc; fprintf('Data %d / %d \n Kappa = tau = 0',ind,Nsongs);
    [m_post,~,~,~] = bayesian_ag_estim(X,v,muini,0,0,hop,iter_bag,nu,0,sm,Nfft,Nw,wtype,0);
    [sdr,sir,sar] = GetSDR(m_post,sm);
    score(1,1,:,ind) = mean([sd si sa]);
        
     % Inf phase
    for nk = 2:Nk
        for nt = 1:Nt
            clc; fprintf('Data %d / %d \n Kappa %d / %d \n Tau %d / %d \n',ind,Nsongs,nk,Nk,nt,Nt);
            kappa = Kappa(nk); tau = Tau(nt);
            [m_post,~,~,~] = bayesian_ag_estim(X,v,muini,kappa,tau,hop,iter_bag,nu,0,sm,Nfft,Nw,wtype,0);
            [sdr,sir,sar] = GetSDR(m_post,sm);
            score(nk,nt,:,ind) = mean([sd si sa]);
        end
    end

end

% Store results
score(1,:,:,:) = repmat(score(1,1,:,:),[1 Nt 1 1]);
save(strcat(out_path,'bag_dev.mat'),'score','Kappa','Tau');
