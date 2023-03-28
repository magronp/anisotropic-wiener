clc; clearvars; close all;
test_or_dev = 'Dev';
global_setup;

% Influence of Kappa onto performance (Fig. 2 in the paper)
scenar = 'oracle';
load(strcat(out_path,'aw_inf_kappa_',scenar,'.mat'))
score_av = mean(score,3);
figure;
subplot(3,1,1); semilogx(Kappa,score_av(:,1),'b.-'); ylabel('SDR (dB)','FontSize',16); % ax=axis; axis([ax(1) 10^7 ax(3) ax(4)]);
subplot(3,1,2); semilogx(Kappa,score_av(:,2),'b.-'); ylabel('SIR (dB)','FontSize',16); % ax=axis; axis([ax(1) 10^7 ax(3) ax(4)]);
subplot(3,1,3); semilogx(Kappa,score_av(:,3),'b.-'); ylabel('SAR (dB)','FontSize',16); % ax=axis; axis([ax(1) 10^7 ax(3) ax(4)]);
xlabel('\kappa','FontSize',16);


% Plot score results
load(strcat(out_path,'aw_sep_',scenar,'.mat'))

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
