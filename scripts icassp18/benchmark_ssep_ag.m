clear all; close all; clc;
test_or_dev = 'Test';
set_settings_bag;

score = zeros(Nalgo,3,Nsongs);

for it=1:Nsongs

    clc; fprintf('Data %d / %d \n',it,Nsongs);
    
    % Load data
    num_piece = datavec(it);
    [sm,x,Sm,X] = get_data_DSD(dataset_path,test_or_dev,num_piece,Fs,Nfft,Nw,hop);
    [F,T,J] = size(Sm);
    vini = abs(Sm).^2+eps;
    
    % Frequencies
    muini = repmat(angle(X),[1 1 J]);
    nu = zeros(F,T,J);
    for j=1:J
        nu(:,:,j) = get_frequencies_qifft(vini(:,:,j))/Nfft;
    end

    %%% Separation
    fprintf('Separation \n');
    Xw = vini.* repmat(X ./ sum(vini,3),[1 1 J]);
    Xc = consistent_wiener(X,vini,gamma_wc,Nfft,Nw,hop);
    Xaw = anisotropic_wiener(X,vini,kappa_aw*ones(F,T,J),hop);
    m_post = bayesian_ag_estim(X,vini,muini,kappa,tau,hop,iter_bag,nu,0,sm,Nfft,Nw,wtype,0);
    
    %%% Synthesis and record
    fprintf('Synthesis, record and score \n');
    sw = real(iSTFT(Xw,Nfft,hop,Nw,wtype));
    scw = real(iSTFT(Xc,Nfft,hop,Nw,wtype));
    saw = real(iSTFT(Xaw,Nfft,hop,Nw,wtype));
    sbag = real(iSTFT(m_post,Nfft,hop,Nw,wtype));
    for j=1:J    
        audiowrite(strcat(audio_path,'song',int2str(it),'_source',int2str(j),'_orig.wav'),sm(j,:),Fs);
        audiowrite(strcat(audio_path,'song',int2str(it),'_source',int2str(j),'_',algos{1},'.wav'),sw(j,:),Fs);
        audiowrite(strcat(audio_path,'song',int2str(it),'_source',int2str(j),'_',algos{2},'.wav'),scw(j,:),Fs);
        audiowrite(strcat(audio_path,'song',int2str(it),'_source',int2str(j),'_',algos{3},'.wav'),saw(j,:),Fs);
        audiowrite(strcat(audio_path,'song',int2str(it),'_source',int2str(j),'_',algos{4},'.wav'),sbag(j,:),Fs);
    end
    
    %%% Score
    [sd,si,sa] = GetSDR(sw,sm); score(1,:,it) = mean([sd si sa]);
    [sd,si,sa] = GetSDR(scw,sm); score(2,:,it) = mean([sd si sa]);
    [sd,si,sa] = GetSDR(saw,sm); score(3,:,it) = mean([sd si sa]);
    [sd,si,sa] = GetSDR(sbag,sm); score(4,:,it) = mean([sd si sa]);
    
end

save(strcat(metrics_path,'separation_bss.mat'),'score');