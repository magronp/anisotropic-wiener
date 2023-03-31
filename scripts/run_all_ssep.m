clc; clearvars; close all;
global_setup;

%%% Check influence / optimal parameters on the dev set
%dev_aw_kappa(dataset_path,out_path,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf);
%dev_aw_kappa(dataset_path,out_path,'informed',Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf);
%dev_bag_kappatau(dataset_path,out_path,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);
%dev_bag_kappatau(dataset_path,out_path,'informed',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);
%dev_vm_kappa(dataset_path,out_path,Fs,Nfft,Nw,hop,wtype,t_chunk);

%%% Benchmark all algorithms on the test set
algos = {'w','unwrap','cw','aw','bag','aw-var'};
%test_algos_ssep(dataset_path,out_path,audio_path,algos,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);
%test_algos_ssep(dataset_path,out_path,audio_path,algos,'informed',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);

%%% Plot results

% Influence of kappa for AW
plot_inf_kappa_aw(out_path,'oracle')
plot_inf_kappa_aw(out_path,'informed')

% Influence of kappa and tau for BAG

% Optimal kappa as a function of sources and window length for AW-var



% Test results - boxplot (remove 'unwrap' since it's too bad)
algos = {'w','cw','aw','bag','aw-var'};
algos_plot = {'Wiener', 'Cons-W', 'AW', 'BAG', 'AW-var'};
test_results_boxplot(out_path,'oracle',algos,algos_plot);
test_results_boxplot(out_path,'informed',algos,algos_plot);

% Test results - mean

% Test results - per source


