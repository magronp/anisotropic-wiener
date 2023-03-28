% Load the signal package
pkg load signal statistics

%%% Parameters used in the various experiments

% Data
Fs = 44100;
Nsongs = 50;
L = 441344;  %song length after stft+istft (samples)

% STFT parameters
Nfft = 4096;
Nw = 4096;
hop = Nw/4;
wtype = 'hann';

% Paths
dataset_path = 'dataset/DSD100/';
out_path = 'outputs/';
audio_path = 'audio_files/';

% Algorithms
algos = {'wiener','consW','AG','BAG'};
%algos = {'w','cw','aw'};
Nalgo = length(algos);

% Filter parameters
gamma_wc = 4;
kappa_aw = 1.6;
kappa = 5; tau=0.5;
iter_bag = 150;

% NMF
Knmf = 10;
iter_nmf = 50;
