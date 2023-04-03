function test_results_display(out_path,scenar,algos,algos_plot,metric,res_per_source,task)

if nargin<7
    task = 'all_sources';
end

if nargin<6
    res_per_source = 0;
end
if nargin<5
    metric = 'bss'
end
if nargin<4
    algos_plot = algos;
end

% Metrics names
switch metric
    case 'bss'
        metric_list = {'SDR', 'SIR','SAR'};
    case 'peass'
        metric_list = {'OPS', 'TPS','IPS', 'APS'};
end
Nmetrics = length(metric_list);

% Sources according to the task
switch task
    case 'all_sources'
        sources = {'bass', 'drums', 'other', 'vocals'};
    case 'singing_sep'
        sources = {'accompaniment', 'vocals'};
end
J = length(sources);

% Size parameters
data_split = 'Test';
Nsongs = get_nsongs(data_split);
Nalgos = length(algos);

% Load the data
score_all = zeros(Nalgos,Nmetrics,J);
for al=1:Nalgos
    load(strcat(out_path,task,'/test_',metric,'_',scenar,'_',algos{al},'.mat'));
    score_all(al,:,:) = transpose(real(squeeze(nanmean(score,3))));
end

% Average over sources
score_av_sces = squeeze(nanmean(score_all,3));
score_df = dataframe([{''},metric_list;algos_plot',num2cell(score_av_sces)]);
fprintf(' -------------- Average over sources ---------------');
display(score_df);

% Results per source
if res_per_source
  for j=1:J
      score_av_sces = squeeze(score_all(:,:,j));
      score_df = dataframe([{''},metric_list;algos_plot',num2cell(score_av_sces)]);
      fprintf(strcat(' --------------', sources{j} ,'---------------'));
      display(score_df);
  end
end

end
