clc; clearvars; close all;
test_or_dev = 'Test';
set_settings_aw;
scenar = 'oracle';

% Anisotropy parameter for separation
switch scenar
    case 'oracle'
        kappa=1.6;
    case 'informed'
        kappa=1;
end

SDR = zeros(Nsongs,Nalgo); SIR = zeros(Nsongs,Nalgo); SAR = zeros(Nsongs,Nalgo);
time_comput = zeros(Nsongs,Nalgo);

for ind=1:Nsongs
   
    % Load data
    clc; fprintf('Data %d / %d \n',ind,Nsongs);
    num_piece = datavec(ind);
    [sm,x,Sm,X] = get_data_DSD(dataset_path,test_or_dev,num_piece,Fs,Nfft,Nw,hop);
    [F,T,J] = size(Sm);
    
    % Variance estimation
    switch scenar
        case 'oracle'
            v = abs(Sm).^2;
        case 'informed'
            Wini=rand(F,K); Hini=rand(K,T);
            v = zeros(F,T,J);
            for j=1:J
                [waux,haux] = NMF(abs(Sm(:,:,j)),Wini,Hini,iter_nmf,1,0);
                v(:,:,j) = (waux*haux).^2;
            end
    end
    
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
    
    % Record
    audiowrite(strcat(audio_path,scenar,'/song',int2str(ind),'mix.wav'),x,Fs);
    for j=1:J
        audiowrite(strcat(audio_path,scenar,'/song',int2str(ind),'_source',int2str(j),'_orig.wav'),sm(j,:),Fs)
        for al = 1:Nalgo
            audiowrite(strcat(audio_path,scenar,'/song',int2str(ind),'_source',int2str(j),'_',algos{al},'.wav'),s_estim(j,:,al),Fs);
        end
    end
    
    % Score
    for al=1:Nalgo
        [sdr,sir,sar] = bss_eval_sources(squeeze(s_estim(:,:,al)),sm);
        SDR(ind,al) = mean(sdr); SIR(ind,al) = mean(sir); SAR(ind,al) = mean(sar);
    end
    
end

% Record score
save(strcat(metrics_path,'separation_',scenar,'.mat'),'SDR','SIR','SAR','time_comput');

% Plot score results
figure;
h11=subplot(1,3,1); boxplot(SDR); title('SDR (dB)'); set(gca,'FontSize',14,'XtickLabel',[]); set(gca,'FontSize',14,'XtickLabel',algos,'XtickLabelRotation',90);
h12=subplot(1,3,2); boxplot(SIR); title('SIR (dB)'); set(gca,'FontSize',14,'XtickLabel',[]); set(gca,'FontSize',14,'XtickLabel',algos,'XtickLabelRotation',90);
h13=subplot(1,3,3); boxplot(SAR); title('SAR (dB)'); set(gca,'FontSize',14,'XtickLabel',[]); set(gca,'FontSize',14,'XtickLabel',algos,'XtickLabelRotation',90);
