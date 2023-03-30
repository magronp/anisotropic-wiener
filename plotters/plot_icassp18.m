clear all; close all; clc;
global_setup;

% Influence of the anisotropy parameters (Fig. 2)
load(strcat(out_path,'dev_bag_oracle.mat'))

sdr = squeeze(mean(score(:,:,1,:),4));
sir = squeeze(mean(score(:,:,2,:),4));
sar = squeeze(mean(score(:,:,3,:),4));

figure;
gcmap = colormap(autumn); gcmap = gcmap(end:-1:1,:); 
gcmap(:,2,:) = 1 - ((0:63)/64).^3;

colormap(gcmap);

subplot(1,3,1); imagesc(sdr); axis xy;
title('SDR (dB)','fontsize',14); set(gca,'xticklabel',Tau,'yticklabel',Kappa);
xlabel('\tau','fontsize',16); ylabel('\kappa','fontsize',16);
subplot(1,3,2); imagesc(sir); axis xy;
title('SIR (dB)','fontsize',14); set(gca,'xticklabel',Tau,'yticklabel',[]);
xlabel('\tau','fontsize',16); 
subplot(1,3,3); imagesc(sar); axis xy;
title('SAR (dB)','fontsize',14); set(gca,'xticklabel',Tau,'yticklabel',[]);
xlabel('\tau','fontsize',16);


% Display test results SDR and PEASS (Table 1)
load(strcat(out_path,'test_bss_bag_oracle.mat'))
bss_av = mean(score, 3);
print('BSS score --')
transpose(bss_av)
load(strcat(out_path,'test_peass_bag_oracle.mat'))
peass_av = mean(mean(score, 4), 3);
print('BSS score --')
transpose(peass_av)

