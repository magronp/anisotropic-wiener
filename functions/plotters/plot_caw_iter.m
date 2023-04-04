function plot_caw_iter(out_path,scenar,task)

if nargin<3
    task = 'all_sources';
end

% Load the results
load(strcat(out_path,task,'/test_caw_iter_',scenar,'.mat'))
sdr = real(squeeze(nanmean(score(1,:,:,:),3)));
[max_iter,~] = size(sdr);
max_iter = max_iter-1;

% Plot
figure;
plot(0:max_iter,sdr(1,1)*ones(1,max_iter+1),'b--',0:max_iter,sdr(:,1),'b-*',0:max_iter,sdr(1,2)*ones(1,max_iter+1),'r-.',0:max_iter,sdr(:,2),'r-o'); hold on;
plot(0:max_iter,sdr(end,1)*ones(1,max_iter+1),'k-');
xlabel('Iterations','fontsize',16); ylabel('SDR (dB)','fontsize',16);
ha=legend('Wiener','CW','AW','CAW'); set(ha,'fontsize',14);

end