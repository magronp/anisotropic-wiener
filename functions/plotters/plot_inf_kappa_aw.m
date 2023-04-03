function plot_inf_kappa_aw(out_path,scenar)
  
% Load the data
load(strcat(out_path,'dev_aw_',scenar,'.mat')),
score_av = mean(score,3);

% Plot
figure;
subplot(3,1,1);
semilogx(Kappa,score_av(:,1),'b.-');
ylabel('SDR (dB)','FontSize',16);
subplot(3,1,2);
semilogx(Kappa,score_av(:,2),'b.-');
ylabel('SIR (dB)','FontSize',16);
subplot(3,1,3); semilogx(Kappa,score_av(:,3),'b.-');
ylabel('SAR (dB)','FontSize',16);
xlabel('\kappa','FontSize',16);

end