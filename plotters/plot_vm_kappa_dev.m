clear all; clc; close all;
global_setup

% Load dev results
load(strcat(out_path, 'dev_vm_kappa.mat'));
[J,Nwin,~] = size(kappa);
sources = {'bass';'drums';'other';'vocals'};

% Kappa vs. window length (similar to Fig. 4 in the paper)
kappa_win = mean(kappa,3);

figure;
for j=1:J
    subplot(1,J,j);
    plot(1:Nwin,kappa_win(j,:),'b-*');
    set(gca,'xticklabel',round(Win_len/Fs*1000));
    xlabel('Window length (ms)','fontsize',16); ylabel('\kappa','fontsize',16);
    title(sources{j})
end;


% Kappa for each source (Nw=4096) (Fig. 5 in the paper)
ind_nw = find(Win_len==4096);
kappa4069 = transpose(squeeze(kappa(:,ind_nw,:)));

figure;
[s, h] = boxplot(kappa4069);
ylabel('\kappa','fontsize',16);
set(gca,'xtick', 1:J, 'xticklabel', sources,'fontsize',16);
delete (h.outliers); delete (h.outliers2);
