clear all; close all; clc;
global_setup;

%%% This script produces the plots in Fig. 1 and 3 from the IWAENC 2018 paper

% Load a toy example data and STFT
[x, Fs_old] = audioread('data/piano.wav');
xaux = resample(mean(x,2),Fs,Fs_old)';
X = STFT(xaux,Nfft,hop,Nw,wtype);
x = iSTFT(X,Nfft,hop,Nw,wtype);
V = abs(X); phX = angle(X);
[F,T] = size(X);
ts = (0:T-1)*hop / Fs;
freq = (1:Nfft/2)*Fs/Nfft;

% Estim kappa and get peaks
[kappa,ph_centered,phaux,f_centr] = estim_kappa_vm(X,Nfft,hop);

% Spectrogram
h = figure;
imagesc(ts,freq,log10(V(:,1:end)+0.01)); axis xy; ylabel('Frequency (Hz)','fontsize',16); xlabel('Time (s)','fontsize',16);
%h.Position = [980 680 387 285];

% Phasogram
phi = phX(f_centr==1);
h = figure; colormap(hsv);
imagesc(ts,freq,phX(:,1:end)); axis xy; ylabel('Frequency (Hz)','fontsize',16); xlabel('Time (s)','fontsize',16);
colorbar;
%h.Position = [980 680 387 285];

% Phase histogram
Nbins = 100;
h = figure;
hist(phi,Nbins,1); xlabel('\phi','fontsize',16); ylabel('Relative frequency','fontsize',16);
%h.Position = [980 680 387 285];

% Centered phasogram
h = figure; colormap(hsv);
imagesc(ts,freq,phaux(:,1:end)); axis xy; ylabel('Frequency (Hz)','fontsize',16); xlabel('Time (s)','fontsize',16);
phiplot = linspace(-pi,pi,Nbins);
p_theo = exp(kappa * cos(phiplot))/(2*pi*besseli(0,kappa));
colorbar;
%h.Position = [980 680 387 285];

% Centered phase histogram
h = figure;
hist(ph_centered,Nbins,1); hold on;
plot(phiplot,p_theo,'r'); xlabel('\psi','fontsize',16); ylabel('Relative frequency','fontsize',16);
%h.Position = [980 680 387 285];
