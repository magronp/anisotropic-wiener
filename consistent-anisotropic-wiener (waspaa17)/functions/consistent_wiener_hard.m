function [Xe,iter] = consistent_wiener_equality(X,V2,Nfft,Nw,hop,stol,wtype)

% V2 : variances |STFT|^2 
% Nfft : number of FFT points
% Nw : STFT window length
% hop : hop size (in samples)
% wtype = window type (Hann, Hamming...)

if nargin<7
    wtype = 'hann';
end

[F,T,J] = size(V2);
Xe = zeros(F,T,J);
mixup = X;
iter  = zeros(1,J-1);

for k=1:J-1
    Vsources = V2(:,:,k:end);
    VS = Vsources(:,:,1);
    VN = sum(Vsources,3)-VS;
    
    [aux,it] = cons_wiener_equality(mixup,VS+eps,VN+eps,Nfft,Nw,hop,stol,wtype);
    iter(k)=it;
    Xe(:,:,k) = aux;
    mixup = mixup - aux;
end
Xe(:,:,J) = X-sum(Xe(:,:,1:J-1),3);

end



function [SE,iter] = cons_wiener_equality(X,VS,VN,Nfft,Nw,hop,stol,wtype)

% CONSWIENER_EQUALITY Wiener filtering with STFT consistency constraint
%
% SE = conswiener_equality(X,VS,VN,nsampl,hop)
%
% Inputs:
% X: nbin x nfram STFT-domain mixture signal
% VS: nbin x nfram STFT-domain source variance
% VN: nbin x nfram STFT-domain noise variance
% gamma: weight of the STFT consistency penalty
% nsampl: number of samples of the original time-domain signal
% hop: STFT hopsize
%
% Outputs:
% SE: nbin x nfram STFT-domain estimated source signal
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2013 Emmanuel Vincent and Jonathan Le Roux
%
% Patent Applied For in Japan: JP2011170190 
%
% Commercial use of this software may be subject to limitations.
%
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

nbin=size(X,1);

%%% Unconstrained Wiener filter %%%
mu=VS./(VS+VN).*X;
Lambda=1./VS+1./VN;

%%% Conjugate gradient %%%
se=real(iSTFT(mu,Nfft,hop,Nw,wtype));
SE=STFT(se,Nfft,hop,Nw,wtype);
b=real(iSTFT(Lambda.*mu,Nfft,hop,Nw,wtype));
r=b-real(iSTFT(Lambda.*SE,Nfft,hop,Nw,wtype));
invM=1./Lambda;
z=real(iSTFT(invM.*STFT(r,Nfft,hop,Nw,wtype),Nfft,hop,Nw,wtype));
%z = r;
p=z;
rsold=sum(sum(r.*z));
iter=0;
converged=false;
while ~converged
    iter=iter+1;
    P=STFT(p,Nfft,hop,Nw,wtype);
    Ap=real(iSTFT(Lambda.*P,Nfft,hop,Nw,wtype));
    alpha=rsold/sum(sum(p.*Ap)+realmin);
    se=se+alpha*p;
    converged=(alpha^2*sum(sum(p.*p)) < stol*sum(sum(se.*se)));
    r=r-alpha*Ap;
    z=real(iSTFT(invM.*STFT(r,Nfft,hop,Nw,wtype),Nfft,hop,Nw,wtype));
    rsnew=sum(sum(r.*z));
    beta=rsnew/(rsold+realmin);
    p=z+beta*p;
    rsold=rsnew;
end
SE=STFT(se,Nfft,hop,Nw,wtype);

end