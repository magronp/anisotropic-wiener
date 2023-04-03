%%% 
%%% This script reproduces the results from our ICASSP 2017 paper
%%%

clc; clearvars; close all;
global_setup;

algos = {'w','cw','unwrap','aw'};
algos_plot = {'Wiener', 'Cons-W', 'Unwrap', 'MMSE'};

%%% Check the influence of kappa on the dev set
dev_aw_kappa(dataset_path,out_path,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf);
dev_aw_kappa(dataset_path,out_path,'informed',Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf);

%%% Run algorithms on the test set
test_algos_ssep(dataset_path,out_path,audio_path,algos,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,max_iter_caw,Knmf,iter_nmf);
test_algos_ssep(dataset_path,out_path,audio_path,algos,'informed',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,max_iter_caw,Knmf,iter_nmf);

%%% Display the results

% Influence of kappa in the oracle scenario (Fig. 2)
plot_inf_kappa_aw(out_path,'oracle')

% Test results (Fig. 3)
test_results_boxplot(out_path,'oracle',algos,algos_plot);
test_results_boxplot(out_path,'informed',algos,algos_plot);

