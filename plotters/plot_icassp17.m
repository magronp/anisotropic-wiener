clc; clearvars; close all;
global_setup;

%%% Influence of Kappa onto performance - oracle (Fig. 2)
load(strcat(out_path,'dev_aw_oracle.mat'))
score_av = mean(score,3);
figure;
subplot(3,1,1); semilogx(Kappa,score_av(:,1),'b.-'); ylabel('SDR (dB)','FontSize',16);
title('Oracle magnitudes','FontSize',16);
subplot(3,1,2); semilogx(Kappa,score_av(:,2),'b.-'); ylabel('SIR (dB)','FontSize',16);
subplot(3,1,3); semilogx(Kappa,score_av(:,3),'b.-'); ylabel('SAR (dB)','FontSize',16);
xlabel('\kappa','FontSize',16);

%%% Influence of Kappa onto performance - informed
load(strcat(out_path,'dev_aw_informed.mat'))
score_av = mean(score,3);
figure;
subplot(3,1,1); semilogx(Kappa,score_av(:,1),'b.-'); ylabel('SDR (dB)','FontSize',16);
title('Estimated magnitudes (informed NMF)','FontSize',16);
subplot(3,1,2); semilogx(Kappa,score_av(:,2),'b.-'); ylabel('SIR (dB)','FontSize',16);
subplot(3,1,3); semilogx(Kappa,score_av(:,3),'b.-'); ylabel('SAR (dB)','FontSize',16);
xlabel('\kappa','FontSize',16);


%%% Boxplot comparing methods on the test set (Fig. 3)

% Oracle scenario
load(strcat(out_path,'test_bss_aw_oracle.mat'))
algos = {'w','unwrap','cw','aw'};
figure;
h11=subplot(1,3,1);
boxplot(SDR); title('SDR (dB)');
set(gca,'FontSize',14,'XtickLabel',[]);
set(gca,'FontSize',14,'XtickLabel',algos,'XtickLabelRotation',90);
h12=subplot(1,3,2);
boxplot(SIR);
title('SIR (dB)');
set(gca,'FontSize',14,'XtickLabel',[]);
set(gca,'FontSize',14,'XtickLabel',algos,'XtickLabelRotation',90);
h13=subplot(1,3,3);
boxplot(SAR);
title('SAR (dB)');
set(gca,'FontSize',14,'XtickLabel',[]);
set(gca,'FontSize',14,'XtickLabel',algos,'XtickLabelRotation',90);

% Informed scenario
load(strcat(out_path,'test_bss_aw_informed.mat'))
figure;
h11=subplot(1,3,1);
boxplot(SDR); title('SDR (dB)');
set(gca,'FontSize',14,'XtickLabel',[]);
set(gca,'FontSize',14,'XtickLabel',algos,'XtickLabelRotation',90);
h12=subplot(1,3,2);
boxplot(SIR);
title('SIR (dB)');
set(gca,'FontSize',14,'XtickLabel',[]);
set(gca,'FontSize',14,'XtickLabel',algos,'XtickLabelRotation',90);
h13=subplot(1,3,3);
boxplot(SAR);
title('SAR (dB)');
set(gca,'FontSize',14,'XtickLabel',[]);
set(gca,'FontSize',14,'XtickLabel',algos,'XtickLabelRotation',90);
