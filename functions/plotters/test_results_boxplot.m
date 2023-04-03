function test_results_boxplot(out_path,scenar,algos,algos_plot,metric,task)

if nargin<6
    task = 'all_sources';
end

if nargin<5
    metric = 'bss'
end
if nargin<4
    algos_plot = algos;
end

% Title (metrics)
switch metric
    case 'bss'
        metric_list = {'SDR (dB)', 'SIR (dB)','SAR (dB)'};
    case 'peass'
        metric_list = {'OPS', 'TPS','IPS', 'APS'};
endswitch
Nmetrics = length(metric_list);

% Size parameters
data_split = 'Test';
Nsongs = get_nsongs(data_split);
Nalgos = length(algos);

% Load the data
score_all = zeros(Nalgos,Nmetrics,Nsongs);
for al=1:Nalgos
    load(strcat(out_path,task,'/test_',metric,'_',scenar,'_',algos{al},'.mat'));
    score_all(al,:,:) = real(squeeze(mean(score,1)));
end

% Plot
figure;
for m=1:Nmetrics
    subplot(1,Nmetrics,m);
    [s, h] = boxplot(transpose(squeeze(score_all(:,m,:))));
    title(metric_list{m});
    set(gca,'xtick', 1:Nalgos, 'xticklabel', algos_plot,'fontsize',14);
end

end