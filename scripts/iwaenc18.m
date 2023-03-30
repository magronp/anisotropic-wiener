%%% 
%%% This script reproduces the results from our iWAENC 2018 paper
%%%

clc; clearvars; close all;
global_setup;

%%% Compute the optimal concentration parameter in the VM model
%dev_vm_kappa(dataset_path,out_path,Fs,Nfft,Nw,hop,wtype,t_chunk);

%%% Run algorithms on the test set
%algos = {'w','aw','aw-var'};
%test_algos_ssep(dataset_path,out_path,audio_path,algos,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);

%%% Plot the results
plot_vm_kappa_dev;