function compute_peass(out_path,audio_path,algos,scenar)

% General parameters
data_split = 'Test';
Nsongs = get_nsongs(data_split);
Nalgos = length(algos);
J = 4;

% Initialize score array
score_all = cell(1, Nalgos);
for al=1:Nalgos
    score_all{al} = zeros(J,4,Nsongs);
end

% PEASS options
options.segmentationFactor = 1;
options.destDir = audio_path;

% Loop over songs
for ind=1:Nsongs

    % Base path
    rec_dir = strcat(audio_path,'all_sources/',scenar,'/song',int2str(ind),'/');

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
            score_all{al}(j,:,ind) = [res.OPS res.TPS res.IPS res.APS];
        end
        originalFiles = circshift(originalFiles,1);
    end
        
    delete(strcat(audio_path,'*eArtif.wav'));
    delete(strcat(audio_path,'*eInterf.wav'));
    delete(strcat(audio_path,'*eTarget.wav'));
    delete(strcat(audio_path,'*true.wav'));

end

% Record PEASS score for all algos
for al=1:Nalgos
    score = score_all{al};
    save(strcat(out_path,'test_peass_',scenar,'_',algos{al},'.mat'),'score');
end

end
