% Consistent anisotropic Wiener filtering - test

clc; clear all; close all;
Fs = 44100; Nw = 2048; Nfft = 2048; hop = Nw/4;
J = 2;
kappa = 1; delta = 10;

%% Generate Data %%

% Load time signals
s1 = audioread('sounds/music.ogg');
s2 = audioread('sounds/vocals.ogg');

% STFT
w = perfect_reco_window(Nw,hop,'hann');
S1 = STFT(s1,Nfft,w,hop); [F,T] = size(S1);
S2 = STFT(s2,Nfft,w,hop);
X = S1+S2;
Sm = zeros(F,T,J); Sm(:,:,1) = S1; Sm(:,:,2) = S2;

% iSTFT (for consistent signal lengths)
sm1 = iSTFT(S1,Nfft,w,hop);
sm2 = iSTFT(S2,Nfft,w,hop);
sm = zeros(J,length(sm1));
sm(1,:) = sm1; sm(2,:) = sm2;
x = sum(sm,1);

clear s1 s2 S1 S2 sm1 sm2;


%% Perform separation %%

V = abs(Sm);
V2 = V.^2;
Sm_approx = V .* exp(1i*repmat(angle(X),[1 1 J]));

% Wiener filtering
G = V2 ./ repmat(sum(V2,3)+eps,[1 1 J]);
X_W = G .* repmat(X,[1 1 J]);

% Consistent Wiener filtering
m_post = X_W(:,:,1); mu = angle(X_W);
[X_CW,iterCW,bssCW] = consistent_anis_wiener_conjgrad(m_post,0,mu,V2,delta,Nfft,w,hop,sm);

%  Anisotropic Wiener filtering (sinus model)
UN = detect_onset_frames(V,Fs,w,hop);
[X_AW,muAW] = phase_unwrap_anisotropic_gaussian(X,Sm_approx,UN,kappa*ones(F,T,J),hop);

% Consistent Anisotropic Wiener filtering
m_post = X_AW(:,:,1); mu = angle(X_AW);
[X_CAW,iterAW,bssCAW] = consistent_anis_wiener_conjgrad(m_post,kappa,mu,V2,delta,Nfft,w,hop,sm);



%% Results %%
sdrCW = squeeze(mean(bssCW(:,:,1),1));
sdrCAW = squeeze(mean(bssCAW(:,:,1),1));

plot(0:iterCW,sdrCW(1)*ones(1,iterCW+1),'b--',0:iterCW,sdrCW,'b-*',0:iterAW,sdrCAW(1)*ones(1,iterAW+1),'r-.',0:iterAW,sdrCAW,'r-o');
hold on; plot(0:max(iterCW,iterAW),sdrCW(end)*ones(1,max(iterCW,iterAW)+1),'k-');
ha=legend('Wiener','CW','AW','CAW'); set(ha,'fontsize',14); xlabel('Iterations','fontsize',16); ylabel('SDR (dB)','fontsize',16);


