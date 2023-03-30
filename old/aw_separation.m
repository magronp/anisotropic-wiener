clc; clearvars; close all;
global_setup;

data_split = 'Test';
scenar = 'informed';

% Anisotropy parameter (optimal value from the Dev set, or default values)
dev_res = strcat(out_path,'aw_dev_',scenar,'.mat');
if isfile(dev_res)
    load(dev_res);
    [~,idk] = max(mean(squeeze(score(:,1,:)), 2));
    kappa = Kappa(idk)
else
    switch scenar
        case 'oracle'
            kappa=1.6;
        case 'informed'
            kappa=1;
    end
end

% Initialize score / time arrays
Nsongs = get_nsongs(data_split)
algos = {'Wiener','ConsWiener','AnisWiener'}; Nalgos = length(algos);
SDR = zeros(Nsongs,Nalgos); SIR = zeros(Nsongs,Nalgos); SAR = zeros(Nsongs,Nalgos);
time_comput = zeros(Nsongs,Nalgos);

% Loop over songs
for ind=1:Nsongs
   
    % Load data
    clc; fprintf('Data %d / %d \n',ind,Nsongs);
    [sm,x,Sm,X] = get_data_DSD(dataset_path,data_split,ind,Fs,Nfft,Nw,hop,t_chunk);
    [F,T,J] = size(Sm);
    
    % Get the variance
    v = estimate_power(Sm, scenar, Knmf, iter_nmf);
    
    % Onset detection
    win = hann(Nw)/sqrt(Nfft);
    UN = detect_onset_frames(sqrt(v),Fs,win,hop);
    
    %%% Separation
    fprintf('Source separation... \n');
    Xe = zeros(F,T,J,Nalgos);
    
    % Wiener filtering
    tic;
    Xe(:,:,:,1) = v ./ (sum(v,3)+eps).*X;
    time_comput(ind,1) = toc;
    
    % Consistent Wiener filtering
    tic;
    Xe(:,:,:,2) = consistent_wiener(X,v,gamma_cw,Nfft,Nw,hop,wtype);
    time_comput(ind,2) = toc;
    
    %  Anisotropic Wiener
    tic;
    Xe(:,:,:,3) = anisotropic_wiener(X,v,kappa*ones(F,T,J),hop,UN);
    time_comput(ind,3) = toc;
    
    % Synthesis
    fprintf('Score... \n');
    s_estim = zeros(J,length(x),Nalgos);
    for al=1:Nalgos
        s_estim(:,:,al) = real(iSTFT(squeeze(Xe(:,:,:,al)),Nfft,hop,Nw,wtype));
    end
    
    % Record (create the folder if needed)
    rec_dir = strcat(audio_path,'ICASSP17/',scenar,'/', int2str(ind), '/');
    mkdir(rec_dir)
    audiowrite(strcat(rec_dir,'mix.wav'),x,Fs);
    for j=1:J
        audiowrite(strcat(rec_dir,'source',int2str(j),'_orig.wav'),sm(j,:),Fs)
        for al = 1:Nalgos
            audiowrite(strcat(rec_dir,'source',int2str(j),'_',algos{al},'.wav'),s_estim(j,:,al),Fs);
        end
    end
    
    % Score
    for al=1:Nalgos
        [sd,si,sa] = GetSDR(squeeze(s_estim(:,:,al)),sm);
        SDR(ind,al) = mean(sd); SIR(ind,al) = mean(si); SAR(ind,al) = mean(sa);
    end
    
end

% Record score
save(strcat(out_path,'aw_test_',scenar,'.mat'),'SDR','SIR','SAR','time_comput', 'algos');
