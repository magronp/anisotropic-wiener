clear all; close all; clc;
global_setup;

data_split = 'Test';

% AW parameter
kappa_aw = 1.6

% AW parameters (optimal values from the Dev set, or default values)
dev_res = strcat(out_path,'vm_kappa_dev.mat');
if isfile(dev_res)
    load(dev_res);
    ind_nw = find(Nw==Win_len)
    mean(squeeze(kappa(:,ind_nw,:)),2)
else
    kappa_aw_var=[2.28 1.26 1.51 1.30];
end


% Initialize score array
Nsongs = get_nsongs(data_split);
algos = {'W','AW','AWvar'}; Nalgos = length(algos);
score = zeros(Nalgos,3,Nsongs);

for ind=1:Nsongs

    clc; fprintf('Data %d / %d \n',ind,Nsongs);
    
    % Load data
    [sm,x,Sm,X] = get_data_DSD(dataset_path,data_split,ind,Fs,Nfft,Nw,hop);
    [F,T,J] = size(Sm);
    v = abs(Sm).^2+eps;
    
    % Frequencies
    muini = repmat(angle(X),[1 1 J]);
    nu = zeros(F,T,J);
    for j=1:J
        nu(:,:,j) = get_frequencies_qifft(v(:,:,j))/Nfft;
    end

    % Separation
    fprintf('Separation \n');
    Xe(:,:,:,1) = v.* repmat(X ./ sum(v,3),[1 1 J]);
    Xe(:,:,:,2) = anisotropic_wiener(X,v,kappa_aw*ones(F,T,J),hop);
    kap = zeros(F,T,J);
    for j=1:J
        kap(:,:,j) = kappa_aw_var(j);
    end
    Xe(:,:,:,3) = anisotropic_wiener(X,v,kap,hop);
    
    % Synthesis
    fprintf('Score... \n');
    s_estim = zeros(J,length(x),Nalgos);
    for al=1:Nalgos
        s_estim(:,:,al) = real(iSTFT(squeeze(Xe(:,:,:,al)),Nfft,hop,Nw,wtype));
    end
    
    % Record audio
    rec_dir = strcat(audio_path,'IWAENC18/', int2str(ind), '/');
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
        score(al,:,ind) = mean([sd si sa]);
    end
    
end

% Record BSS Eval score
save(strcat(out_path,'aw_var_test.mat'),'score', 'algos');
