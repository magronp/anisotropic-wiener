%%% 
%%% This script reproduces the results from our iWAENC 2018 paper
%%%

clc; clearvars; close all;
global_setup;

algos = {'w','aw','aw-var'};
algos_plot = {'Wiener', 'AW', 'AW-var'};

%%% Before experiments, you can plot the von Mises density and check the histograms (Fig. 1, 2, and 3)
plot_vm_pdf;
plot_vm_histos;

%%% Compute the optimal concentration parameter in the VM model
dev_vm_kappa(dataset_path,out_path,Fs,Nfft,Nw,hop,wtype,t_chunk);

%%% Run algorithms on the test set
test_algos_ssep(dataset_path,out_path,audio_path,algos,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,max_iter_caw,Knmf,iter_nmf);

%%% Plot the results

% Optimal kappa over window lengths and per source (Fig.4 and 5)
plot_vm_kappa(out_path);

% Test results (Table 1)
test_results_display(out_path,'oracle',algos,algos_plot,'bss',1);
