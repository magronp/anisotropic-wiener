clc; clearvars; close all;
test_or_dev = 'Dev';
set_settings_aw;
scenar = 'oracle';

% Anisotropy parameters for learning
%Kappa = 10.^(-2:1:2);
Kappa = [0.01 0.1 10.^(0:0.2:1)];
Nkappa = length(Kappa);

% Score
score = zeros(Nkappa,3,Nsongs);


for it=1:Nsongs
   
    % Source generation
    clc; fprintf('Data %d / %d \n',it,Nsongs);
    num_piece = datavec(it);
    [sm,x,Sm,X] = get_data_DSD(dataset_path,test_or_dev,num_piece,Fs,Nfft,Nw,hop);
    [F,T,J] = size(Sm);
    
    % Magnitude estimation (oracle or KLNMF)
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
            
        case 'semi-informed'
            Wini=rand(F,K); Hini=rand(K,T);
            Ktot = J*K;
            Wis = zeros(F,Ktot);
            % learn the basis from the isolated spectro
            for j=1:J
                waux = NMF(abs(Sm(:,:,j)).^2,Wini,Hini,iter_dico,0,0);   % ISNMF in the semi-informed setting (useful for complex ISNMF experiments)
                Wis(:,(j-1)*K+1:j*K)=waux;
            end
            
            % NMF on the mix
            [~,His] = NMF(abs(X).^2,Wis,rand(Ktot,T),iter_nmf,0,0,1,ones(F,T),0);
            v = zeros(F,T,J);
            for j=1:J
                v(:,:,j) = Wis(:,(j-1)*K+1:j*K)*His((j-1)*K+1:j*K,:);
            end
    end
    
    % Onset frames detection
    win = hann(Nw)/sqrt(Nfft);
    UN = detect_onset_frames(sqrt(v),Fs,win,hop);   % use onset locations...
    %UN = zeros(K,T);                               % ...or don't
   
    % AW
    se = zeros(size(sm));
    for kap=1:Nkappa
        clc; fprintf('Data %d / %d \n Kappa %d / %d \n',it,Nsongs,kap,Nkappa)
        
        % Concentration parameters - uniform or dependent on j,f,t
        kappa = Kappa(kap).* ones(F,T,J);
        %kap_var = Kappa(kap).*(1-G);
        
        % AW
        Xaw = anisotropic_wiener(X,v,kappa,hop,UN);

        % synthesis
        se = real(iSTFT(Xaw,Nfft,hop,Nw,wtype));
        
         % Score
        [sd,si,sa] = bss_eval_sources(se,sm);
        score(kap,:,it) = [mean(sd) mean(si) mean(sa)];    
    end
    
end

% Save score
save(strcat(metrics_path,'learning_kappa_',scenar,'.mat'),'score','Kappa');

% Plot results
score_av = mean(score,3);
figure;
subplot(3,1,1); semilogx(Kappa,score_av(:,1),'b.-'); ylabel('SDR (dB)','FontSize',16); % ax=axis; axis([ax(1) 10^7 ax(3) ax(4)]);
subplot(3,1,2); semilogx(Kappa,score_av(:,2),'b.-'); ylabel('SIR (dB)','FontSize',16); % ax=axis; axis([ax(1) 10^7 ax(3) ax(4)]);
subplot(3,1,3); semilogx(Kappa,score_av(:,3),'b.-'); ylabel('SAR (dB)','FontSize',16); % ax=axis; axis([ax(1) 10^7 ax(3) ax(4)]);
xlabel('\kappa','FontSize',16);