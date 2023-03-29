clc; clearvars; close all;
global_setup;

data_split = 'Dev';
scenar = 'oracle';

% Range of concentration parameter to test
Kappa = [0.01 0.1 10.^(0:0.2:1)];
Nkappa = length(Kappa);

% Score
Nsongs = get_nsongs(data_split)
score = zeros(Nkappa,3,Nsongs);

for ind=1:Nsongs
   
    % Source generation
    clc; fprintf('Data %d / %d \n',ind,Nsongs);
    [sm,x,Sm,X] = get_data_DSD(dataset_path,data_split,ind,Fs,Nfft,Nw,hop,t_chunk);
    [F,T,J] = size(Sm);
    
    % Get the variance
    v = estimate_power(Sm, scenar, Knmf, iter_nmf);
    
    % Onset frames detection
    win = hann(Nw)/sqrt(Nfft);
    UN = detect_onset_frames(sqrt(v),Fs,win,hop);
   
    % AW
    se = zeros(size(sm));
    for kap=1:Nkappa
        clc; fprintf('Data %d / %d \n Kappa %d / %d \n',ind,Nsongs,kap,Nkappa)
        
        % AW
        kappa = Kappa(kap).* ones(F,T,J);
        Xaw = anisotropic_wiener(X,v,kappa,hop,UN);

        % Synthesis and score
        se = real(iSTFT(Xaw,Nfft,hop,Nw,wtype));
        [sd,si,sa] = GetSDR(se,sm);
        score(kap,:,ind) = mean([sd si sa]);
    end
    
end

% Save score
save(strcat(out_path,'aw_dev_',scenar,'.mat'),'score','Kappa');
