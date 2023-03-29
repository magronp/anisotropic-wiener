% Load the signal package
pkg load signal statistics

%%% Parameters used in the various experiments

% Data
Fs = 44100;
Nsongs = 50;
%L = 441344;
t_chunk = [70 71];

% STFT parameters
Nfft = 4096;
Nw = 4096;
hop = Nw/4;
wtype = 'hann';

% Paths
dataset_path = 'dataset/DSD100/';
out_path = 'outputs/';
audio_path = 'audio_files/';

% NMF
Knmf = 10;
iter_nmf = 50;

% BAG
iter_bag = 150;
