%%% 
%%% This script reproduces the results from our ICASSP 2018 paper
%%%

clc; clearvars; close all;
global_setup;

%%% Check the influence of kappa and tau on the dev set
%dev_bag_kappatau(dataset_path,out_path,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);

%%% Run algorithms on the test set
algos = {'w','cw','aw', 'bag'};
%test_algos_ssep(dataset_path,out_path,audio_path,algos,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);

%%% Plot the results
plot_icassp18;

