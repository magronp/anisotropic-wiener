clc; clearvars; close all;
global_setup;

% Check influence / optimal parameters on the dev set
%dev_aw_kappa(dataset_path,out_path,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf);
%dev_aw_kappa(dataset_path,out_path,'informed',Fs,Nfft,Nw,hop,wtype,t_chunk,Knmf,iter_nmf);
%dev_bag_kappatau(dataset_path,out_path,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);
%dev_bag_kappatau(dataset_path,out_path,'informed',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);
%dev_vm_kappa(dataset_path,out_path,Fs,Nfft,Nw,hop,wtype,t_chunk);

% All algorithms on the test set
algos = {'w','unwrap','cw','aw','bag','aw-var'};
test_algos_ssep(dataset_path,out_path,audio_path,algos,'oracle',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);
test_algos_ssep(dataset_path,out_path,audio_path,algos,'informed',Fs,Nfft,Nw,hop,wtype,t_chunk,iter_bag,Knmf,iter_nmf);
