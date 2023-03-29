function [x,X,F,T,ts,freq] = get_data_MAPS(dataset_path,Fs,Nfft,Nw,hop,ind,time_interval,wtype)

if nargin<8
    wtype = 'hann';
end

if nargin<7
    time_interval = [0 10];
end

if nargin<6
    ind = randi(30,1,1);
end

%%% Get data path

fid = fopen(strcat(dataset_path,'MAPS/pieces/list_pieces.txt'));
T = textscan(fid, '%s', 'Delimiter','\n');
fclose(fid);
name = T{1}; name = name(ind);
L = char(strcat(dataset_path,'MAPS/pieces/MAPS_MUS-',name,'_StbgTGd2.wav'));


%%% Read audio data
[s,Fs_old] = audioread(L);
s=mean(s,2); s=s(time_interval(1)*Fs_old+1:time_interval(2)*Fs_old);
xaux = resample(s,Fs,Fs_old)';


%%% STFT
X = STFT(xaux,Nfft,hop,Nw,wtype);
x = iSTFT(X,Nfft,hop,Nw,wtype);

[F,T] = size(X);
ts = (0:T-1)*hop / Fs;
freq = (1:Nfft/2)*Fs/Nfft;

end
