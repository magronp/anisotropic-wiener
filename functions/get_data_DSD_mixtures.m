function [x,X,ts,freq] = get_data_DSD_mixtures(dataset_path,test_or_dev,num_piece,Fs,Nfft,Nw,hop,ttotal,wtype)

Fs_old=44100;
J = 1;

if nargin<9
    wtype = 'hann';
end

if nargin<8
    ttotal = [70 80];
end

%%% Get files path
dir_path = strcat(dataset_path,'/Mixtures/',test_or_dev);
aux = dir(dir_path);
song_name = aux(num_piece+2).name;
L = strcat(dir_path,'/',song_name,'/mixture.wav');


%%% Read time-domain signals
t_beg = ttotal(1); t_end = ttotal(2);
aux = audioread(L,Fs_old*[t_beg t_end]);      % read source
aux=mean(aux,2)';                             % average channels
x = resample(aux,Fs,Fs_old);              % resample


%%% STFT
X = STFT(x,Nfft,hop,Nw,wtype);
x = real(iSTFT(X,Nfft,hop,Nw,wtype));

ts = (0:size(X,2)-1)*hop / Fs;
freq = (1:Nfft/2)*Fs/Nfft;

end

