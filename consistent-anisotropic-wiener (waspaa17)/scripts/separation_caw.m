% Compare the Wiener filters on the test dataset

clc; clear all; close all;
test_or_dev = 'Test';
scenario = 'oracle';
set_settings_caw;

% Score
score = zeros(Nalgo,3,Nsongs);
iterations_pcg = zeros(2,Nsongs);

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
    
    % Separation
    se = zeros(J,length(x),Nalgo);
    
    % Wiener filtering
    X_w = variances ./ (sum(variances,3)+eps) .* repmat(X,[1 1 J]);
    se(:,:,1) = real(iSTFT(X_w,Nfft,hop,Nw,wtype));
    
    % Anisotropic Wiener filtering
    X_aw = anisotropic_wiener(X,variances,kappa_caw*ones(F,T,J),hop);
    se(:,:,2) = real(iSTFT(X_aw,Nfft,hop,Nw,wtype));
    
    % Consistent Wiener filtering
    [X_cw,it] = caw(X_w,variances,0,delta_caw,Nw,hop,wtype);
    se(:,:,3) = real(iSTFT(X_cw,Nfft,hop,Nw,wtype));
    iterations_pcg(1,ind) = it;

    % Consistent anisotropic Wiener filtering
    [X_caw,it] = caw(X_aw,variances,kappa_caw,delta_caw,Nw,hop,wtype);
    se(:,:,4) = real(iSTFT(X_caw,Nfft,hop,Nw,wtype));
    iterations_pcg(2,ind) = it;

    % Record
    for j=1:J
        audiowrite(strcat(audio_path,'song',int2str(ind),'_source',int2str(j),'_orig.wav'),sm(j,:),Fs)
        for al = 1:Nalgo
            audiowrite(strcat(audio_path,'song',int2str(ind),'_source',int2str(j),'_',algos{al},'.wav'),se(j,:,al),Fs);
        end
    end

    % Score
    for al = 1:Nalgo
        [sd,si,sa] = GetSDR(se(:,:,al),sm); score(al,:,ind) = mean([sd si sa]);
    end
end

% Record scores
save(strcat(metrics_path,'separation_',scenario,'.mat'),'score','iterations_pcg');
