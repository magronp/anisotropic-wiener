function [SE,iter,cost,score] = caw_multisources(Xini,variances,mu,kappa,delta,Nfft,w,hop,Nit,sm,bss)
(Xini,variances,kappa,delta,Nw,hop,wtype,tol_pcg,max_iter,sm)

if nargin<11
    bss =0;
end

if nargin<8
    tol_pcg = 1e-6;
end

[F,T,J]=size(Xini);
Jp=J-1;

wlen=2*(F-1);

% AG sources moments
lambda = besseli(1,kappa) ./ besseli(0,kappa);
rho = (besseli(2,kappa).*besseli(0,kappa) - besseli(1,kappa).^2 )./ besseli(0,kappa).^2;
gamma = (1-lambda.^2).* variances;
c = rho.*variances .*exp(2*1i*mu) ;

gj = gamma(:,:,1:Jp); cj = c(:,:,1:Jp);
gJ = gamma(:,:,J); cJ = c(:,:,J);
detGj = gj.^2 - abs(cj).^2+eps;
detGJ = gJ.^2 - abs(cJ).^2+eps;
gDj = gj./detGj; cDj = cj./detGj;
gDJ = gJ./detGJ; cDJ = cJ./detGJ;

% Preconditioning auxiliary moments
gtilde = detGj ./ ( (gj+delta*(wlen-hop)/wlen*detGj).^2 - abs(cj).^2 ) .* ( gj+delta*(wlen-hop)/wlen*detGj );
ctilde = detGj ./ ( (gj+delta*(wlen-hop)/wlen*detGj).^2 - abs(cj).^2 ) .* ( cj );

% Auxiliary mixture moments
gX = sum(gtilde,3) + gJ;
cX = sum(ctilde,3) + cJ;
detGX = gX.^2 - abs(cX).^2+eps;

A = (gtilde.*gX-ctilde.*conj(cX))./detGX;
B = (gX.*ctilde-cX.*gtilde)./detGX;

%%% Initialization (AW) )%%%
SE=Xini(:,:,1:Jp);

%%% Conjugate gradient %%%
wei=repmat([1; 2*ones(F-2,1); 1],[1 T Jp]);

se = iSTFT(SE,Nfft,hop,w);
SSe = STFT(se,Nfft,hop,w);
FSE=SE-SSe;
r=-delta*FSE;

aux = gtilde.*r + ctilde.*conj(r);
z = aux - A.*sum(aux,3) + B.*conj(sum(aux,3)) ;
    
P = z;

rsold=real(sum(sum(sum(wei.*conj(r).*z))));
iter=0;
%converged=false;

SDR =[]; SIR = []; SAR = []; cost = [];
if bss
    se(J,:) = sum(sm)-sum(se(1:Jp,:),1);
    [sd,si,sa] = GetSDR(se,sm);
    SDR = [SDR  sd]; SIR = [SIR  si]; SAR = [SAR  sa];
end
    

%while ~converged
for iter=1:Nit
    %iter=iter+1;
    
    FP = P - STFT(iSTFT(P,Nfft,hop,w),Nfft,hop,w);
    sumP = sum(P,3);
    AP = gDj.* P - cDj .*conj(P) + gDJ.* sumP - cDJ .*conj(sumP) +delta*FP;
    
    alpha=rsold/real(sum(sum(sum(wei.*conj(P).*AP)))+realmin);
    SE=SE+alpha*P;
    
    if bss
        se(1:Jp,:)=iSTFT(SE,Nfft,hop,w);
        se(J,:) = sum(sm)-sum(se(1:Jp,:),1);
        [sd,si,sa] = GetSDR(se,sm);
        SDR = [SDR  sd]; SIR = [SIR  si]; SAR = [SAR  sa];
    end
        
    
    %converged=(sum(sum(sum(alpha^2*real(P.*conj(P))))) < 1e-6*sum(sum(sum(real(SE.*conj(SE))))));
    r=r-alpha*AP;
    aux = gtilde.*r + ctilde.*conj(r);
    z = aux - A.*sum(aux,3) + B.*conj(sum(aux,3)) ;
    
    
    rsnew=real(sum(sum(sum(wei.*conj(r).*z))));
    beta=rsnew/(rsold+realmin);
    P=z+beta*P;
    rsold=rsnew;
end

score = [];
if bss
   score = zeros(J,Nit+1,3);
   score(:,:,1) = SDR; score(:,:,2) = SIR; score(:,:,3) = SAR;
end


end
