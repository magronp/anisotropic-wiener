% Load the needed packages
%pkg unload signal statistics
pkg load signal statistics

% Data
Fs = 44100;
Nsongs = 50;
t_chunk = [70 70.5];

% STFT parameters
Nfft = 4096;
Nw = 4096;
hop = Nw/4;
wtype = 'hann';

% Paths
dataset_path = 'data/DSD100/';
out_path = 'outputs/';
audio_path = 'audio_files/';

% NMF
Knmf = 10;
iter_nmf = 50;

% BAG
iter_bag = 150;
