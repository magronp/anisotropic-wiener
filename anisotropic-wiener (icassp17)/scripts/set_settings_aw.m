% Set the settings used in the experiments for the anisotropic Wiener
% filter (icassp 2017)

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

J = 4;
L = 441344;  %song length after stft+istft (samples)

% STFT parameters
Nfft = 4096;
Nw = 4096;
hop = Nw/4;
wtype = 'hann';

% Paths
dataset_path = 'datasets/DSD100/';
audio_path = 'anisotropic-wiener/audio_files/';
metrics_path = 'anisotropic-wiener/metrics/';

% Algorithms
algos = {'w','cw','aw'};
Nalgo = length(algos);

% NMF
K = 10; Ktot = K*J;
iter_nmf = 50; 

% Consistency weight (CW)
gamma_wc = 4;
