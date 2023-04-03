% Load the needed packages
pkg load signal statistics dataframe

% Data
Fs = 44100;
t_chunk = [70 80];

% STFT parameters
Nfft = 4096;
Nw = 4096;
hop = Nw/4;
wtype = 'hann';

% Paths
dataset_path = 'data/DSD100/';
out_path = 'outputs/';
audio_path = 'audio_files/';

% Iterative algos parameters (NMF, BAG, CAW)
Knmf = 10;
iter_nmf = 50;
iter_bag = 150;
max_iter_caw = 60;


% Anisotropy parameter
kappa_caw = 1;
delta_caw = 10;
kappa_caw = 0.8;
delta_caw = 1;

