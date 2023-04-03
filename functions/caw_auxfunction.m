function [Se,cost,score_bss] = caw_auxfunction(m_post,kappa,mu,V2,delta,Nfft,w,hop,Nit,sm)

% Mixture STFT (F*T)
% m_post : posterior moments in the AG model (F*T) (gen. Wiener)
% kappa : anisotropy parameter
% mu : prior phase (mixture -> Wiener)
% V2 : power estimate
% delta : consistency weight
% Nfft : number of FFT points
% w : STFT window
% hop : hop size (in samples)
% Nit : Number of iterations

bss=1;
if nargin<10
    bss =0;
end

%First, compute the covariance in the AG model
lambda = besseli(1,kappa) ./ besseli(0,kappa);
rho = (besseli(2,kappa).*besseli(0,kappa) - besseli(1,kappa).^2 )./ besseli(0,kappa).^2;
gamma = (1-lambda.^2).* V2;
c = rho.*V2 .*exp(2*1i*mu) ;

% Mixture and posterior covariance
gamma_X = sum(gamma,3);      
c_X = sum(c,3);
detGX = gamma_X.^2 - abs(c_X).^2+eps;
        
gamma_post = abs(gamma(:,:,1) - ( gamma_X .* (gamma(:,:,1).^2+abs(c(:,:,1)).^2) - 2 * gamma(:,:,1) .* real(c(:,:,1).*conj(c_X))  )  ./ detGX);
c_post = c(:,:,1) - (2*gamma(:,:,1).*gamma_X.*c(:,:,1) - gamma(:,:,1).^2 .* c_X - c(:,:,1).^2 .* conj(c_X)  )  ./ detGX;
detG = gamma_post.^2-abs(c_post).^2;

% Init estimated sources
Se = m_post; 
cost = zeros(1,Nit);
if bss
    score_bss = zeros(2,3,Nit);
end

% Loop
for iter=1:Nit

    % Update auxiliary sources
    se = iSTFT(Se,Nfft,w,hop); se=se';
    Stilde = STFT(se,Nfft,w,hop);
    if bss
        se2 = sum(sm,1)-se;
        [sd,si,sa]=bss_eval_sources([se;se2],sm);
        score_bss(:,:,iter) = [sd si sa];
    end
       
    % Compute cost
    incons = abs(Stilde-Se).^2;
    LS = 2*( gamma_post .* abs(Se-m_post).^2 - real(conj(c_post).*(Se-m_post).^2) )./(detG+eps);
    cost(iter) = sum(LS(:)+2*delta*incons(:));         
    
    % Update sources
   Se = ( (1+delta*gamma_post).*m_post   + delta*(gamma_post+delta*detG).*Stilde + delta*c_post.*conj(Stilde-m_post)     )./(1+2*delta*gamma_post+delta^2*detG);
    
end

end


