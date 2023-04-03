function dev_caw_delta(dataset_path,out_path,scenar,Fs,Nfft,Nw,hop,wtype,max_iter_caw,t_chunk,Knmf,iter_nmf,task)

data_split = 'Dev';

% Consistency weight range
Delta = 10.^(-3:3);
Nd = length(Delta);

% Load the optimal Kappa parameter
kappa_aw = load_param_aw(out_path,scenar,task);

% Initialize score array
Nsongs = get_nsongs(data_split);
score = zeros(Nd,3,Nsongs);

for ind=1:Nsongs
   
    % Load the data
    [sm,x,Sm,X] = get_data_DSD(dataset_path,data_split,ind,Fs,Nfft,Nw,hop,t_chunk,wtype,task);
    [F,T,J] = size(Sm);
    
    % Get the variance
    v = estimate_power(Sm, scenar, Knmf, iter_nmf);
    
    % Onset frames detection
    win = hann(Nw)/sqrt(Nfft);
    UN = detect_onset_frames(sqrt(v),Fs,win,hop);
   
    % Initial filtering
    X_aw = anisotropic_wiener(X,v,kappa_aw*ones(F,T,J),hop,UN);
    
    % Loop over consistency weight
    for ind_d=1:Nd
        clc; fprintf('-- Dev CAW -- '); fprintf(scenar);
        fprintf('\n Song %d / %d  \n Delta %d / %d \n',ind,Nsongs,ind_d,Nd)
        delta = Delta(ind_d);
        
        % Consistent anisotropic Wiener filtering
        X_caw = caw(X_aw,v,kappa_aw,delta,Nw,hop,wtype,1e-6,max_iter_caw);
        
        % Synthesis and score
        se = real(iSTFT(X_caw,Nfft,hop,Nw,wtype));
        [sd,si,sa] = GetSDR(se,sm);
        score(ind_d,:,ind) = mean([sd si sa]);
        
    end
    
end

% Save score (create the directory if needed)
out_dir = strcat(out_path,task,'/');
mkdir(out_dir);
save(strcat(out_dir,'dev_caw_',scenar,'.mat'),'score','Delta');

end


function kappa_aw = load_param_aw(out_path, scenar, task)
% AW anisotropy parameter (optimal value from the Dev set, or default)
dev_res = strcat(out_path,task,'/dev_aw_',scenar,'.mat');
if isfile(dev_res)
    load(dev_res);
    [~,idk] = max(mean(squeeze(score(:,1,:)), 2));
    kappa_aw = Kappa(idk);
else
    switch task
        case 'all_sources'
            switch scenar
                case 'oracle'
                    kappa_aw = 1.6;
                case 'informed'
                    kappa_aw = 1;
            end
        case 'singing_sep'
            switch scenar
                case 'oracle'
                    kappa_aw = 1;
                case 'informed'
                    kappa_aw = 0.8;
            end
    end
    
end

end
