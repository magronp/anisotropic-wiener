function dev_aw_kappa(dataset_path,out_path,scenar,Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf,task)

if nargin<12
    task = 'all_sources';
end

data_split = 'Dev';

% Range of concentration parameter to test
Kappa = [0.01 0.1 10.^(0:0.2:1)];
Nkappa = length(Kappa);

% Initialize score array
Nsongs = get_nsongs(data_split);
score = zeros(Nkappa,3,Nsongs);

for ind=1:Nsongs
   
    % Load the data
    [sm,x,Sm,X] = get_data_DSD(dataset_path,data_split,ind,Fs,Nfft,Nw,hop,t_chunk,wtype,task);
    [F,T,J] = size(Sm);
    
    % Get the variance
    v = estimate_power(Sm, scenar, Knmf, iter_nmf);
    
    % Onset frames detection
    win = hann(Nw)/sqrt(Nfft);
    UN = detect_onset_frames(sqrt(v),Fs,win,hop);
   
    % AW
    for kap=1:Nkappa
        clc; fprintf('-- Dev AW -- '); fprintf(scenar);
        fprintf('\n Song %d / %d \n Kappa %d / %d \n',ind,Nsongs,kap,Nkappa);
        
        % AW
        kappa = Kappa(kap).* ones(F,T,J);
        Xaw = anisotropic_wiener(X,v,kappa,hop,UN);

        % Synthesis and score
        se = real(iSTFT(Xaw,Nfft,hop,Nw,wtype));
        [sd,si,sa] = GetSDR(se,sm);
        score(kap,:,ind) = mean([sd si sa]);
    end
    
end

% Save score (create the directory if needed)
out_dir = strcat(out_path,task,'/');
mkdir(out_dir);
save(strcat(out_dir,'dev_aw_',scenar,'.mat'),'score','Kappa');

end