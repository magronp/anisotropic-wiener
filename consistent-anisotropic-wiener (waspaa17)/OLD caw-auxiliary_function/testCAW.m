% Source separation benchmark on DSD100 database using a variety of methods
% for phase reconstruction

clc; clear all; close all;

% Parameters
Fs = 44100; Nw = 512*4; Nfft = 512*4; hop = Nw/4;
source_type = 'DSD100';

Nit = 100;
kappa =1.6;
delta =1;

% Generate the sources
gen_sources_time;
gen_sources_TF_inst;
smaux = [sm(1,:)+sm(2,:)+sm(3,:) ; sm(4,:)];
Smaux(:,:,1) = Sm(:,:,1)+  Sm(:,:,2)+ Sm(:,:,3);
Smaux(:,:,2) = Sm(:,:,4);
clear sm; clear Sm;
sm = smaux; Sm=Smaux;

J=2;

V=abs(Sm);
V2 = V.^2;
Sm_approx = V .* exp(1i*repmat(angle(X),[1 1 J]));

% Wiener filtering
G = V2 ./ repmat(sum(V2,3)+eps,[1 1 J]);
X_W = G .* repmat(X,[1 1 J]);

% Consistent Wiener filtering
m_post = X_W(:,:,1); mu = angle(X_W);
[X_CW,costW,bssCW] = consistent_anis_wiener(m_post,0,mu,V2,delta,Nfft,w,hop,Nit,sm);


%  Von Mises - Anisotropic gaussian estimate
UN = detect_onset_frames(V,Fs,w,hop);
[X_AW,muAW] = phase_unwrap_anisotropic_gaussian(X,Sm_approx,UN,kappa*ones(F,T,J),hop);

% Consistent Wiener filtering
m_post = X_AW(:,:,1); mu = angle(X_AW);
[X_CAW,costAW,bssCAW] = consistent_anisotropic_wiener_aux(m_post,kappa,mu,V2,delta,Nfft,w,hop,Nit,sm);


% Synthesis
se = zeros(4,2,length(x));
for j=1:2
    se(1,j,:) = iSTFT(X_W(:,:,j),Nfft,w,hop);
    se(3,j,:) = iSTFT(X_AW(:,:,j),Nfft,w,hop);
end
se(2,1,:) = iSTFT(X_CW,Nfft,w,hop); se(2,2,:) = x-squeeze(se(2,1,:));
se(4,1,:) = iSTFT(X_CAW,Nfft,w,hop); se(4,2,:) = x-squeeze(se(4,1,:));
    
    
% Score
SDR = zeros(1,2); SIR=SDR; SAR=SDR;
for al=1:4
    [sd,si,sa] = bss_eval_sources(squeeze(se(al,:,:)),sm);
    SDR(al) = mean(sd); SIR(al) = mean(si); SAR(al) = mean(sa);
end


plot(0:Nit-1,SDR(1)*ones(1,Nit),'b--',0:Nit-1,mean(squeeze(bssCW(:,1,:))),'b-*',0:Nit-1,SDR(3)*ones(1,Nit),'r-.',0:Nit-1,mean(squeeze(bssCAW(:,1,:))),'r-o')
ha=legend('Wiener','CW','AW','CAW'); set(ha,'fontsize',14);
xlabel('Iterations','fontsize',16);
ylabel('SDR (dB)','fontsize',16);

