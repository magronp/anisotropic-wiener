%%% 
%%% This script reproduces the results from our WASPAA 2017 paper
%%%

clc; clearvars; close all;
global_setup;

task = 'singing_sep';
algos = {'w','aw','cw','caw'};
algos_plot = {'Wiener', 'AW', 'CW','CAW'};

%%% Optimal parameters

% First, check the influence of kappa for AW on the dev set (needed for CAW)
dev_aw_kappa(dataset_path,out_path,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf,task);
dev_aw_kappa(dataset_path,out_path,'informed',Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf,task);

% Now, check the influence of delta for CW
dev_cw_delta(dataset_path,out_path,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf,task);
dev_cw_delta(dataset_path,out_path,'informed',Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf,task);

% And finally check the influence of delta for CAW
dev_caw_delta(dataset_path,out_path,'oracle',Fs,Nfft,Nw,hop,wtype,max_iter_caw,t_chunk,Knmf,iter_nmf,task);
dev_caw_delta(dataset_path,out_path,'informed',Fs,Nfft,Nw,hop,wtype,max_iter_caw,t_chunk,Knmf,iter_nmf,task);


%%% Run algorithms on the test set
test_algos_ssep(dataset_path,out_path,audio_path,algos,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,max_iter_caw,Knmf,iter_nmf,task);
test_algos_ssep(dataset_path,out_path,audio_path,algos,'informed',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,max_iter_caw,Knmf,iter_nmf,task);

% Results over iterations
test_caw_iter(dataset_path,out_path,algos,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,max_iter_caw,Knmf,iter_nmf,task);


%%% Display the results

% Influence of delta (Fig. 1)
plot_inf_delta_caw(out_path,'oracle',task)
plot_inf_delta_caw(out_path,'informed',task)

% Test results (Table 1)
test_results_display(out_path,'oracle',algos,algos_plot,'bss',1,task);

% Results over iterations (Fig. 2)
plot_caw_iter(out_path,'oracle',task);

