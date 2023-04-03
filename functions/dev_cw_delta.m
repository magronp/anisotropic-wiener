function dev_cw_delta(dataset_path,out_path,scenar,Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf,task)

data_split = 'Dev';

% Consistency weight range
Delta = 10.^(-3:3);
Nd = length(Delta);

% Initialize score array
Nsongs = get_nsongs(data_split);
score = zeros(Nd,3,Nsongs);

for ind=1:Nsongs
   
    % Load the data
    [sm,x,Sm,X] = get_data_DSD(dataset_path,data_split,ind,Fs,Nfft,Nw,hop,t_chunk,wtype,task);
    [F,T,J] = size(Sm);
    
    % Get the variance
    v = estimate_power(Sm, scenar, Knmf, iter_nmf);
   
    % Loop over consistency weight
    for ind_d=1:Nd
        clc; fprintf('-- Dev CW -- '); fprintf(scenar);
        fprintf('\n Song %d / %d  \n Delta %d / %d \n',ind,Nsongs,ind_d,Nd)
        delta = Delta(ind_d);
        
        % Consistent Wiener filtering
        Xe = consistent_wiener(X,v,delta,Nfft,Nw,hop,wtype);

        % Synthesis and score
        se = real(iSTFT(Xe,Nfft,hop,Nw,wtype));
        [sd,si,sa] = GetSDR(se,sm);
        score(ind_d,:,ind) = mean([sd si sa]);
        
    end
    
end

% Save score (create the directory if needed)
out_dir = strcat(out_path,task,'/');
mkdir(out_dir);
save(strcat(out_dir,'dev_cw_',scenar,'.mat'),'score','Delta');

end
