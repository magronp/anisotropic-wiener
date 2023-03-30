function dev_bag_kappatau(dataset_path,out_path,scenar,Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf)

data_split = 'Dev';

% Anisotropy parameters
Kappa = [0 0.05 0.1 0.5 1 5 10]; Nk=length(Kappa);
Tau = [0 0.1 0.5 1 5 10]; Nt = length(Tau);

% Initialize score array
Nsongs = get_nsongs(data_split);
score = zeros(Nk,Nt,3,Nsongs);

for ind=1:Nsongs
   
    % Load the data
    [sm,x,Sm,X] = get_data_DSD(dataset_path,data_split,ind,Fs,Nfft,Nw,hop,t_chunk,wtype);
    [F,T,J] = size(Sm);
    
    % Get the variance
    v = estimate_power(Sm, scenar, Knmf, iter_nmf);
    
    % Instantaneous frequencies
    nu = zeros(F,T,J);
    for j=1:J
        nu(:,:,j) = get_frequencies_qifft(v(:,:,j))/Nfft;
    end

    % kappa=0 (no need to test all values for tau in this case)
    clc; fprintf('-- Dev BAG -- '); fprintf(scenar);
    fprintf('\n Song %d / %d \n Kappa = tau = 0',ind,Nsongs);
    [m_post,~,~,~] = bayesian_ag_estim(X,v,0,0,hop,iter_bag,nu,0,sm,Nfft,Nw,wtype,0);
    se = real(iSTFT(m_post,Nfft,hop,Nw,wtype));
    [sd,si,sa] = GetSDR(se,sm);
    score(1,1,:,ind) = mean([sd si sa]);
        
     % Looper over anisotropy parameters
    for nk = 2:Nk
        for nt = 1:Nt
            clc; fprintf('-- Dev BAG -- '); fprintf(scenar);
            fprintf('\n Song %d / %d \n Kappa %d / %d \n Tau %d / %d \n',ind,Nsongs,nk,Nk,nt,Nt);
            kappa = Kappa(nk); tau = Tau(nt);
            [m_post,~,~,~] = bayesian_ag_estim(X,v,kappa,tau,hop,iter_bag,nu,0,sm,Nfft,Nw,wtype,0);
            se = real(iSTFT(m_post,Nfft,hop,Nw,wtype));
            [sd,si,sa] = GetSDR(se,sm);
            score(nk,nt,:,ind) = mean([sd si sa]);
        end
    end
    
end

% Save score
score(1,:,:,:) = repmat(score(1,1,:,:),[1 Nt 1 1]);
save(strcat(out_path,'dev_bag_',scenar,'.mat'),'score','Kappa', 'Tau');

end