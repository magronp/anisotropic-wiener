%%% 
%%% This script reproduces the results from our ICASSP 2017 paper
%%%

clc; clearvars; close all;
global_setup;

%%% Check the influence of kappa on the dev set
%dev_aw_kappa(dataset_path,out_path,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf);
%dev_aw_kappa(dataset_path,out_path,'informed',Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf);

%%% Run algorithms on the test set
%algos = {'w','unwrap','cw','aw'};
%test_algos_ssep(dataset_path,out_path,audio_path,algos,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);
%test_algos_ssep(dataset_path,out_path,audio_path,algos,'informed',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);

%%% Plot results
plot_icassp17;

