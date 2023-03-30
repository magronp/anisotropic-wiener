function [m_post,mu,C_MAP,scorebss] = bayesian_ag_estim(X,vini,kappa,tau,hop,Niter,nu,computecost,sm,Nfft,Nw,wtype,upv)

if nargin<13
    upv=1;
end

[F,T,J] = size(vini);

% Anisotropy parameters
lambda = besseli(1,kappa) / besseli(0,kappa) *sqrt(pi)/2;
rho=besseli(2,kappa)./besseli(0,kappa) - lambda.^2;

% Initial components
v = vini;
mu = repmat(angle(X),[1 1 J]);
m = lambda * sqrt(v) .* exp(1i*mu);
gamma = (1-lambda^2)*v;
c = rho*v .* exp(2i*mu);

% Cost
if computecost
    C_MAP = zeros(1,Niter+1);
    scorebss = zeros(Niter+1,3);
end


% EM
for iter=1:Niter
    
    % --------------------------------- E step

    % ----- update estimated sum moments
    m_X = sum(m,3);
    gamma_X = sum(gamma,3);      
    c_X = sum(c,3);
    detGamma = gamma_X.^2 - abs(c_X).^2;

    % ----- posterior moments
    m_post = m + ( (gamma.*gamma_X - c.*conj(c_X)).*(X-m_X) + (c.*gamma_X - gamma.*c_X).* conj(X-m_X)  ) ./ (detGamma+eps) ;
    gamma_post = gamma - ( gamma_X .* (gamma.^2+abs(c).^2) - 2 * gamma .* real(c.*conj(c_X))  )  ./ (detGamma+eps);
    c_post = c - (2*gamma.*gamma_X.*c - gamma.^2 .* c_X - c.^2 .* conj(c_X)  )  ./ (detGamma+eps);


    
    % Compute the cost
    if computecost
        se = real(iSTFT(m_post,Nfft,hop,Nw,wtype));
        C_MAP(iter) = compute_cost(X,m_X,gamma_X,c_X,mu,tau,hop,nu) ;
        [sd,si,sa] = GetSDR(se,sm);
        scorebss(iter,:) = [mean(sd) mean(si) mean(sa) ];
    end
    
    
    % --------------------------------- M step

    if upv
        % ----- auxiliary parameters
        p = ((1-lambda^2)*(gamma_post+abs(m_post).^2)-rho*real(exp(-2*1i*mu).*(c_post+m_post.^2))  )/((1-lambda^2)^2-rho^2)  ;
        q = 2*lambda*(rho-(1-lambda^2))* real( m_post .* exp(-1i*mu) ) /((1-lambda^2)^2-rho^2);

        % ----- variance param
        v = 1/16 * (q+sqrt(16*p+q.^2)).^2;
    end

    % ----- phase param
    beta_part = 2*lambda*(1-lambda^2-rho) ./  (  ( (1-lambda^2)^2-rho^2 ) * sqrt(v)  ) .* m_post   ;
    for t=2:T-1
       mu(:,t,:)=angle( beta_part(:,t,:) + tau*(  exp(1i* (mu(:,t-1,:)+2*pi*hop*nu(:,t,:) ) ) +  exp(1i* (mu(:,t+1,:)-2*pi*hop*nu(:,t+1,:)))     ) );
    end
    

    % ----- update m, gamma and c
    m = lambda * sqrt(v) .* exp(1i*mu);
    gamma = (1-lambda^2)*v;
    c = rho*v .* exp(2i*mu);

end

% Finally, one E step for having the most up to date posterior mean
m_X = sum(m,3);
gamma_X = sum(gamma,3);      
c_X = sum(c,3);
detGamma = gamma_X.^2 - abs(c_X).^2;
m_post = m + ( (gamma.*gamma_X - c.*conj(c_X)).*(X-m_X) + (c.*gamma_X - gamma.*c_X).* conj(X-m_X)  ) ./ (detGamma+eps) ;


% Last cost
if computecost
    se = real(iSTFT(m_post,Nfft,hop,Nw,wtype));
    C_MAP(iter+1) = compute_cost(X,m_X,gamma_X,c_X,mu,tau,hop,nu) ;
    [sd,si,sa] = GetSDR(se,sm);
    scorebss(iter+1,:) = [mean(sd) mean(si) mean(sa) ];
end
    
end



function [cmap] = compute_cost(X,m_X,gamma_X,c_X,mu,tau,hop,nu) 

[F,~,J] =size(mu);

detGamma = gamma_X.^2 - abs(c_X).^2;
logc = log(detGamma)/2 + ( gamma_X .* abs(X-m_X).^2  + real( (X-m_X).^2 .* conj(c_X) ) ) ./ (detGamma+eps);

logphi = 0;
for j=1:J
    mu_m = [zeros(F,1) mu(:,1:end-1,j)  ];
    mu_p = [mu(:,2:end,j) zeros(F,1)]; 
    logphi =logphi +  tau* real( exp(-1i*mu(:,:,j)) .* ( exp( 1i* (mu_m+2*pi*hop*nu(:,:,j) ) ) +exp(1i* (mu_p-2*pi*hop*nu(:,:,j))) ) );
end

cmap = sum(logphi(:)-logc(:)) ;
   
end

