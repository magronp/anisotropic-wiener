function test_algos_ssep(dataset_path,out_path,audio_path,algos,scenar,Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf)

% General parameters
J = 4;
data_split = 'Test';
Nsongs = get_nsongs(data_split);
Nalgos = length(algos);

% Algorithms parameters
kappa_aw = load_param_aw(out_path,scenar);
[kappa_bag, tau_bag] = load_param_bag(out_path,scenar);
kappa_aw_var = load_param_aw_var(out_path);
gamma_cw = 4;

% Initialize score / time arrays
score_all = cell(1, Nalgos);
time_all = cell(1, Nalgos);
for al=1:Nalgos
    score_all{al} = zeros(J,3,Nsongs);
    time_all{al} = zeros(1,Nsongs);
end

% Loop over songs
for ind=1:Nsongs
   
    % Load data
    [sm,x,Sm,X] = get_data_DSD(dataset_path,data_split,ind,Fs,Nfft,Nw,hop,t_chunk);
    [F,T,J] = size(Sm);
    
    % Get the variance
    v = estimate_power(Sm, scenar, Knmf, iter_nmf);
    
    % Already record the mixture and original sources
    rec_dir = strcat(audio_path,'all_sources/',scenar,'/song',int2str(ind),'/');
    mkdir(rec_dir)
    audiowrite(strcat(rec_dir,'mix.wav'),x,Fs);
    for j=1:J
        audiowrite(strcat(rec_dir,'source',int2str(j),'_orig.wav'),sm(j,:),Fs);
    end
    
    % Precompute inst. frequencies in some cases
    if or(any(ismember(algos,'unwrap')),any(ismember(algos,'bag')))
        nu = zeros(F,T,J);
        for j=1:J
            nu(:,:,j) = get_frequencies_qifft(v(:,:,j))/Nfft;
        end
    end
    
    % Precompute onsets in some cases
    if or(any(ismember(algos,'unwrap')),any(ismember(algos,'aw')))
        win = hann(Nw)/sqrt(Nfft);
        UN = detect_onset_frames(sqrt(v),Fs,win,hop);
    end
    
    % Loop over algorithms
    for al=1:Nalgos
        clc; fprintf('-- Test -- '); fprintf(scenar);
        fprintf('\n Song %d / %d -- Algo %d / %d \n',ind,Nsongs,al,Nalgos);
        
        % Appli the algo
        fprintf('Separation... \n');
        tic;
        
        switch algos{al}
            case 'w'
                Xe = v ./ (sum(v,3)+eps).*X;
            case 'cw'
                Xe = consistent_wiener(X,v,gamma_cw,Nfft,Nw,hop,wtype);
            case 'aw'
                Xe = anisotropic_wiener(X,v,kappa_aw*ones(F,T,J),hop,UN);
            case 'bag'
                Xe = bayesian_ag_estim(X,v,kappa_bag,tau_bag,hop,iter_bag,nu,0,sm,Nfft,Nw,wtype,0);
            case 'aw-var'
                kap = zeros(F,T,J);
                for j=1:J
                    kap(:,:,j) = kappa_aw_var(j);
                end
                Xe = anisotropic_wiener(X,v,kap,hop);
            case 'unwrap'
                [Xe,~] = sep_unwrap(X,v,nu,hop,UN);
            
        end
              
        % Store time
        time_all{j}(ind) = toc;
        
        % Synthesis
        s_estim = real(iSTFT(Xe,Nfft,hop,Nw,wtype));
        
        % Score
        fprintf('Score... \n');
        [sd,si,sa] = GetSDR(s_estim,sm);
        score_all{al}(:,:,ind) = [sd si sa];
        
        % Record estimates
        fprintf('Recording... \n');
        for j=1:J
            audiowrite(strcat(rec_dir,'source',int2str(j),'_',algos{al},'.wav'),s_estim(j,:),Fs);
        end
    end

end

% Record score and time for all algos
for al=1:Nalgos
    score = score_all{al};
    time_comput = time_all{al};
    save(strcat(out_path,'test_bss_',scenar,'_',algos{al},'.mat'),'score','time_comput');
end

end


function kappa_aw = load_param_aw(out_path, scenar)
% AW anisotropy parameter (optimal value from the Dev set, or default)
dev_res = strcat(out_path,'dev_aw_',scenar,'.mat');
if isfile(dev_res)
    load(dev_res);
    [~,idk] = max(mean(squeeze(score(:,1,:)), 2));
    kappa_aw = Kappa(idk);
else
    switch scenar
        case 'oracle'
            kappa_aw = 1.6;
        case 'informed'
            kappa_aw = 1;
    end
end

end


function [kappa_bag,tau_bag] = load_param_bag(out_path, scenar)
% BAG anisotropy parameters (optimal values from the Dev set, or default)
dev_res = strcat(out_path,'dev_bag_',scenar,'.mat');
if isfile(dev_res)
    load(dev_res);
    sdrav = mean(squeeze(score(:,:,1,:)), 3);
    [~, idt] = max(max(sdrav,[],1));
    [~, idk] = max(max(sdrav,[],2));
    kappa_bag = Kappa(idk); tau_bag = Tau(idk);
else
    kappa_bag = 5;
    tau_bag = 0.5;
end

end


function kappa_aw_var = load_param_aw_var(out_path)
% AW-var anisotropy parameter (optimal value from the Dev set, or default)
dev_res = strcat(out_path,'dev_vm_kappa.mat');
if isfile(dev_res)
    load(dev_res);
    ind_nw = find(Nw==Win_len);
    %kappa_aw_var = mean(squeeze(kappa(:,ind_nw,:)),2);
    kappa_aw_var = median(squeeze(kappa(:,ind_nw,:)),2);
else
    %kappa_aw_var=[2.28 1.26 1.51 1.30];  % old values
    %kappa_aw_var=[2.49 1.27 1.73 1.31];  % mean
    kappa_aw_var=[2.29 1.27 1.51 1.30];  % median
end

end



