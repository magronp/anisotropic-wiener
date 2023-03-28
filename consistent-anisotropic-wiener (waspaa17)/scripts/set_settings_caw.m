% Set the settings used in the experiments for CAW

Fs = 44100;

% Data
Nsongs = 50;
datavec = 1:Nsongs;
switch test_or_dev
    case 'Dev'
        dataNaN=[1 18 29 38 49];
    case 'Test'
        dataNaN=[6 34 36 40];
end
datavec(dataNaN)=[];
datavec = datavec(1:min(Nsongs,length(datavec)));
Nsongs = length(datavec);

% STFT parameters
Nfft = 4096;
Nw = 4096;
hop = Nw/4;
wtype = 'hann';

% Paths
dataset_path = 'datasets/DSD100/';
audio_path = 'consistent-anisotropic-wiener/audio_files/';
metrics_path = 'consistent-anisotropic-wiener/metrics/';

% Algorithms
algos = {'w','ca','aw','caw'};
Nalgo = length(algos);
max_iter = 60;

% NMF
K = 50;
iter_nmf = 100;

% Anisotropy parameter
switch scenario
    case 'oracle'
        kappa_caw = 1;
        delta_caw = 10;
    case 'informed'
        kappa_caw = 0.8;
        delta_caw = 1;
end

