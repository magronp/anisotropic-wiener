function plot_inf_delta_caw(out_path,scenar,task)
  
if nargin<3
    task = 'all_sources';
end

% Load the data
load(strcat(out_path,task,'/dev_cw_',scenar,'.mat')),
SDR_cw = mean(squeeze(score(:,1,:)),2);
load(strcat(out_path,task,'/dev_caw_',scenar,'.mat')),
SDR_caw = mean(squeeze(score(:,1,:)),2);

% Plot
figure;
semilogx(Delta,SDR_cw,'b*-'); hold on; semilogx(Delta,SDR_caw,'ro-');
title(scenar,'fontsize',16);
xlabel('\delta','FontSize',16);
ylabel('SDR (dB)','FontSize',16); 
ha=legend('CW','CAW'); set(ha,'FontSize',14);

end