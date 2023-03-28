clc; clearvars; close all;
global_setup;

data_split = 'Test';
scenar = 'oracle';

% Anisotropy parameter for separation
switch scenar
    case 'oracle'
        kappa=1.6;
    case 'informed'
        kappa=1;
end

Nsongs = get_nsongs(data_split)
algos = {'wiener','consW','AW'}; Nalgos = length(algos);
SDR = zeros(Nsongs,Nalgo); SIR = zeros(Nsongs,Nalgo); SAR = zeros(Nsongs,Nalgo);
time_comput = zeros(Nsongs,Nalgo);

for ind=1:Nsongs
   
    % Load data
    clc; fprintf('Data %d / %d \n',ind,Nsongs);
    [sm,x,Sm,X] = get_data_DSD(dataset_path,data_split,ind,Fs,Nfft,Nw,hop);
    [F,T,J] = size(Sm);
    
    % Get the variance
    v = estimate_power(Sm, scenar, Knmf, iter_nmf)
    
    % Onset detection
    win = hann(Nw)/sqrt(Nfft);
    UN = detect_onset_frames(sqrt(v),Fs,win,hop);   % use onset locations (as in the ICASSP2017 paper)...
    %UN = zeros(J,T);                               % ...or don't
    
    %%% Separation
    fprintf('Source separation... \n');
    Xe = zeros(F,T,J,Nalgo);
    
    % Wiener filtering
    tic;
    Xe(:,:,:,1) = v ./ (sum(v,3)+eps).*X;
    time_comput(ind,1) = toc;
    
    % Consistent Wiener filtering
    tic;
    Xe(:,:,:,2) = consistent_wiener(X,v,gamma_wc,Nfft,Nw,hop,wtype);
    time_comput(ind,2) = toc;
    
    %  Anisotropic Wiener
    tic;
    Xe(:,:,:,3) = anisotropic_wiener(X,v,kappa*ones(F,T,J),hop,UN);
    time_comput(ind,3) = toc;
    
    %%% Score
    fprintf('Score... \n');
    s_estim = zeros(J,length(x),Nalgo);
    
    % Synthesis
    for al=1:Nalgo
        s_estim(:,:,al) = real(iSTFT(squeeze(Xe(:,:,:,al)),Nfft,hop,Nw,wtype));
    end
    
    % Record (create the folder if needed)
    rec_dir = strcat(audio_path,'ICASSP17/',scenar,'/', int2str(ind), '/');
    mkdir(rec_dir)
    audiowrite(strcat(rec_dir,'mix.wav'),x,Fs);
    for j=1:J
        audiowrite(strcat(rec_dir,'source',int2str(j),'_orig.wav'),sm(j,:),Fs)
        for al = 1:Nalgo
            audiowrite(strcat(rec_dir,'source',int2str(j),'_',algos{al},'.wav'),s_estim(j,:,al),Fs);
        end
    end
    
    % Score
    for al=1:Nalgo
        [sdr,sir,sar] = bss_eval_sources(squeeze(s_estim(:,:,al)),sm);
        SDR(ind,al) = mean(sdr); SIR(ind,al) = mean(sir); SAR(ind,al) = mean(sar);
    end
    
end

% Record score
save(strcat(out_path,'aw_sep_',scenar,'.mat'),'SDR','SIR','SAR','time_comput');
