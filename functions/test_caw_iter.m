function test_caw_iter(dataset_path,out_path,algos,scenar,Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,max_iter_caw,Knmf,iter_nmf,task)

if nargin<15
    task = 'all_sources';
end

% General parameters
switch task
    case 'all_sources'
        J=4;
    case 'singing_sep'
        J=2;
end
data_split = 'Test';
Nsongs = get_nsongs(data_split);
Nalgos = length(algos);

% Algorithms parameters
kappa_aw = load_param_aw(out_path,scenar,task);
gamma_cw = load_param_cw(out_path,scenar,task);
delta_caw = load_param_caw(out_path,scenar,task);

% Initialize score array
score = zeros(3,max_iter_caw+1,Nsongs,2);

% Loop over songs
for ind=1:Nsongs
   
    clc; fprintf('-- Test CW/CAW over iterations -- '); fprintf(scenar);
    fprintf('\n Song %d / %d',ind,Nsongs);
        
    % Load data
    [sm,x,Sm,X] = get_data_DSD(dataset_path,data_split,ind,Fs,Nfft,Nw,hop,t_chunk,wtype,task);
    [F,T,J] = size(Sm);
    
    % Get the variance
    v = estimate_power(Sm, scenar, Knmf, iter_nmf);
    
    % Precompute onsets
    win = hann(Nw)/sqrt(Nfft);
    UN = detect_onset_frames(sqrt(v),Fs,win,hop);
    
    % Precompute Wiener and AW
    X_w = v ./ (sum(v,3)+eps).*X;
    X_aw = anisotropic_wiener(X,v,kappa_aw*ones(F,T,J),hop,UN);
    
    % CW
    [~,~,aux] = caw(X_w,v,0,delta_caw,Nw,hop,wtype,0,max_iter_caw,sm);
    score(:,:,ind,1) = squeeze(mean(aux{1},1));
    
    % CAW
    [~,~,aux] = caw(X_aw,v,kappa_aw,delta_caw,Nw,hop,wtype,0,max_iter_caw,sm);
    score(:,:,ind,2) = squeeze(mean(aux{1},1));

end

% Record score over iterations
out_dir = strcat(out_path,task,'/');
mkdir(out_dir);
save(strcat(out_dir,'test_caw_iter_',scenar,'.mat'),'score');

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


function gamma_cw = load_param_cw(out_path, scenar, task)
% CW parameter (optimal value from the Dev set for 'singing_sep', or default for 'all_sources')

switch task
    case 'all_sources'
        gamma_cw = 4;
    case 'singing_sep'
        dev_res = strcat(out_path,task,'/dev_cw_',scenar,'.mat');
        if isfile(dev_res)
            load(dev_res);
            [~,idk] = max(mean(squeeze(score(:,1,:)), 2));
            gamma_cw = Delta(idk);
        else
            switch scenar
                case 'oracle'
                    gamma_cw = 10;
                case 'informed'
                    gamma_cw = 1;
            end
end

end

end


function delta_caw = load_param_caw(out_path, scenar, task)
  
% CAW parameter (optimal value from the Dev set)
dev_res = strcat(out_path,task,'/dev_caw_',scenar,'.mat');
if isfile(dev_res)
    load(dev_res);
    [~,idk] = max(mean(squeeze(score(:,1,:)), 2));
    delta_caw = Delta(idk);
else
    switch scenar
        case 'oracle'
            delta_caw = 10;
        case 'informed'
            delta_caw = 1;
    end
end

end
