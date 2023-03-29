clear all; close all; clc;
global_setup;

data_split = 'Test';

% General parameters
J = 4;
Nsongs = get_nsongs(data_split);
algos = {'W','CW','AW', 'BAG'}; Nalgos = length(algos);
score = zeros(Nalgos,3,Nsongs);

% PEASS options
options.segmentationFactor = 1;
options.destDir = audio_path;
score = zeros(Nalgos,4,J,Nsongs);

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
        for al = 1:Nalgos
            clc; fprintf('data %d / %d \n source %d / %d \n algo  %d / %d ',ind,Nsongs,j,J,al,Nalgos);
            est_path = strcat(rec_dir,'source',int2str(j),'_',algos{al},'.wav');
            res = PEASS_ObjectiveMeasure(originalFiles,est_path,options);
            score(al,:,j,ind) = [res.OPS res.TPS res.IPS res.APS];
        end
        originalFiles = circshift(originalFiles,1);
    end
        
    delete(strcat(audio_path,'*eArtif.wav'));
    delete(strcat(audio_path,'*eInterf.wav'));
    delete(strcat(audio_path,'*eTarget.wav'));
    delete(strcat(audio_path,'*true.wav'));

end

% Record PEASS score
save(strcat(out_path,'bag_test_peass.mat'),'score','algos');
