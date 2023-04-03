%%% 
%%% This script reproduces the results from our WASPAA 2017 paper
%%%

clc; clearvars; close all;
global_setup;

task = 'singing_sep';
algos = {'w','aw','cw','caw'};

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

%%% Display the results



% Record scores
save(strcat(metrics_path,'learning_caw_',scenario,'.mat'),'score','Delta');

% Plot the SDR
SDR = squeeze(mean(score(:,1,:,:),4));

figure;
semilogx(Delta,SDR(1,:),'b*-'); hold on; semilogx(Delta,SDR(2,:),'ro-');
title(scenario,'fontsize',16); xlabel('\delta','FontSize',16); ylabel('SDR (dB)','FontSize',16); 
ha=legend('Isotropic','Anisotropic'); set(ha,'FontSize',14);

