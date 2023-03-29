clear all; close all; clc;
global_setup;

% General parameters
J = 4;
Nsongs = get_nsongs(data_split);
algos = {'W','CW','AW', 'BAG'}; Nalgos = length(algos);
score = zeros(Nalgos,3,Nsongs);

% PEASS options
options.segmentationFactor = 1;
options.destDir = audio_path;
score = zeros(4,4,J,Nsongs);

% Loop over songs
for ind=1:Nsongs

    % Base path
    rec_dir = strcat(audio_path,'ICASSP18/', int2str(ind), '/');

    % Original Files path
    originalFiles = cell(J,1);
    for j=1:J
        originalFiles{j} = strcat(rec_dir,'source',int2str(j),'_orig.wav')
    end

    % PEASS
    for j=1:J
        clc; fprintf('data %d / %d \n source %d / %d',ind,Nsongs,j,J);
        
        % Wiener
        est_cnmf = strcat(audio_path,'song',int2str(ind),'_source',int2str(j),'_wiener.wav');
        res = PEASS_ObjectiveMeasure(originalFiles,est_cnmf,options);
        score(1,:,j,ind) = [res.OPS res.TPS res.IPS res.APS];
        
        % Consistent Wiener
        est_cnmf = strcat(audio_path,'song',int2str(ind),'_source',int2str(j),'_consW.wav');
        res = PEASS_ObjectiveMeasure(originalFiles,est_cnmf,options);
        score(2,:,j,ind) = [res.OPS res.TPS res.IPS res.APS];
 
         % AW (ICASSP 2017 style)
        est_cnmf = strcat(audio_path,'song',int2str(ind),'_source',int2str(j),'_AW.wav');
        res = PEASS_ObjectiveMeasure(originalFiles,est_cnmf,options);
        score(3,:,j,ind) = [res.OPS res.TPS res.IPS res.APS]; 
        
        % AG
        est_cnmf = strcat(audio_path,'song',int2str(ind),'_source',int2str(j),'_AG.wav');
        res = PEASS_ObjectiveMeasure(originalFiles,est_cnmf,options);
        score(4,:,j,ind) = [res.OPS res.TPS res.IPS res.APS];        
        
        originalFiles = circshift(originalFiles,1);
    end
        
    delete(strcat(audio_path,'*eArtif.wav'));
    delete(strcat(audio_path,'*eInterf.wav'));
    delete(strcat(audio_path,'*eTarget.wav'));
    delete(strcat(audio_path,'*true.wav'));

end

save(strcat(metrics_path,'bag_test_peass.mat'),'score');
