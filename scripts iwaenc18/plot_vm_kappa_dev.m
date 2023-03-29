
%load


% Plot kappa vs. window length (Fig. 4 in the paper)
figure;
for j=1:J
    subplot(1,J,j);
    plot(1:Nwin,kappa(j,:),'b-*');
    set(gca,'xticklabel',round(winleng/Fs*1000));
    xlabel('Window length (ms)','fontsize',16); ylabel('\kappa','fontsize',16);
end;


% Boxplot for a given Nw=4096 (Fig. 5 in the paper)
kappa(sum(isnan(kappa),2)==1,:) = [];
figure;
boxplot(kappa,'symbol',''); ylabel('\kappa','fontsize',16); set(gca,'xticklabel',{'bass';'drums';'other';'vocals'},'fontsize',16);
