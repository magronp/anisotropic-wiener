function plot_vm_kappa(out_path)

% Load dev results
load(strcat(out_path, 'dev_vm_kappa.mat'));
[J,Nwin,~] = size(kappa);
sources = {'bass';'drums';'other';'vocals'};

% Kappa vs. window length
kappa_win = mean(kappa,3);

figure;
for j=1:J
    subplot(1,J,j);
    plot(1:Nwin,kappa_win(j,:),'b-*');
    set(gca,'xticklabel',round(Win_len/Fs*1000));
    xlabel('Window length (ms)','fontsize',16); ylabel('\kappa','fontsize',16);
    title(sources{j})
end;


% Kappa for each source (Nw=4096)
ind_nw = find(Win_len==4096);
kappa4069 = transpose(squeeze(kappa(:,ind_nw,:)));

figure;
[s, h] = boxplot(kappa4069);
ylabel('\kappa','fontsize',16);
set(gca,'xtick', 1:J, 'xticklabel', sources,'fontsize',16);
delete (h.outliers); delete (h.outliers2);

end