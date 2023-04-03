%%% 
%%% This script reproduces the results from our ICASSP 2018 paper
%%%

clc; clearvars; close all;
global_setup;

algos = {'w','cw','aw', 'bag'};
algos_plot = {'Wiener', 'Cons-W', 'AW', 'BAG'};

%%% Check the influence of kappa and tau on the dev set
dev_bag_kappatau(dataset_path,out_path,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);

%%% Run algorithms on the test set

test_algos_ssep(dataset_path,out_path,audio_path,algos,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,max_iter_caw,Knmf,iter_nmf);

% You might also want to compute the PEASS score for this paper (oracle)
compute_peass(out_path,audio_path,algos,'oracle')

%%% Display the results

% Influence of kappa and tau in the oracle scenario (Fig. 2)
plot_inf_kappatau_bag(out_path,'oracle');

% Display test SDR and PEASS (Table 1)
test_results_display(out_path,'oracle',algos,algos_plot,'bss');
test_results_display(out_path,'oracle',algos,algos_plot,'peass');
