% Consistent anisotropic Wiener filtering - test

clc; clear all; close all;
Fs = 44100; Nw = 2048; Nfft = 2048; hop = Nw/4; wtype = 'hann';
J = 2;
kappa = 1; delta = 10;

%%% Generate Data %%%

% Load time signals
s1 = audioread('data/music.ogg');
s2 = audioread('data/vocals.ogg');

% STFT
S1 = STFT(s1',Nfft,hop,Nw,wtype);
S2 = STFT(s2',Nfft,hop,Nw,wtype);
[F,T] = size(S1);
X = S1+S2;
Sm = zeros(F,T,J); Sm(:,:,1) = S1; Sm(:,:,2) = S2;

% iSTFT (for consistent signal lengths)
sm1 = iSTFT(S1,Nfft,hop,Nw,wtype);
sm2 = iSTFT(S2,Nfft,hop,Nw,wtype);
sm = zeros(J,length(sm1));
sm(1,:) = sm1; sm(2,:) = sm2;
x = sum(sm,1);

clear s1 s2 S1 S2 sm1 sm2;

%%% Perform (oracle) separation, synthesis and record audio %%%
v = abs(Sm).^2;

% Wiener
X_w = v ./ (sum(v,3)+eps).*X;
s_w = iSTFT(X_w,Nfft,hop,Nw,wtype);
audiowrite('audio_files/music_wiener.ogg', s_w(1,:), Fs);
audiowrite('audio_files/vocals_wiener.ogg', s_w(2,:), Fs);

% Consistent Wiener
X_cw = consistent_wiener(X,v,delta,Nfft,Nw,hop,wtype);
s_cw = iSTFT(X_w,Nfft,hop,Nw,wtype);
audiowrite('audio_files/music_cw.ogg', s_w(1,:), Fs);
audiowrite('audio_files/vocals_cw.ogg', s_w(2,:), Fs);

% Anisotropic Wiener
win = hann(Nw)/sqrt(Nfft);
UN = detect_onset_frames(sqrt(v),Fs,win,hop);
X_aw = anisotropic_wiener(X,v,kappa*ones(F,T,J),hop,UN);
s_aw = iSTFT(X_w,Nfft,hop,Nw,wtype);
audiowrite('audio_files/music_aw.ogg', s_w(1,:), Fs);
audiowrite('audio_files/vocals_aw.ogg', s_w(2,:), Fs);

% Consistent anisotropic Wiener
X_caw = caw(X_aw,v,kappa,delta,Nw,hop,wtype);
s_caw = iSTFT(X_w,Nfft,hop,Nw,wtype);
audiowrite('audio_files/music_caw.ogg', s_w(1,:), Fs);
audiowrite('audio_files/vocals_caw.ogg', s_w(2,:), Fs);

