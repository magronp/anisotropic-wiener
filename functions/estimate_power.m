
function v = estimate_power(Sm, scenar, K, n_iter)

[F,T,J] = size(Sm);

if nargin<4
    n_iter = 50;
end

if nargin<3
    K = 10;
end

if nargin<2
    scenar='oracle';
end

switch scenar
    case 'oracle'
        v = abs(Sm).^2;
        
    case 'informed'
        Wini=rand(F,K); Hini=rand(K,T);
        v = zeros(F,T,J);
        for j=1:J
            [waux,haux] = NMF(abs(Sm(:,:,j)),Wini,Hini,n_iter,1,0);
            v(:,:,j) = (waux*haux).^2;
        end
        
    case 'semi-informed'
        Wini=rand(F,K); Hini=rand(K,T);
        Ktot = J*K;
        Wis = zeros(F,Ktot);
        % learn the basis from the isolated spectro
        for j=1:J
            waux = NMF(abs(Sm(:,:,j)).^2,Wini,Hini,iter_dico,0,0);
            Wis(:,(j-1)*K+1:j*K)=waux;
        end
        
        % NMF on the mix
        [~,His] = NMF(abs(X).^2,Wis,rand(Ktot,T),n_iter,0,0,1,ones(F,T),0);
        v = zeros(F,T,J);
        for j=1:J
            v(:,:,j) = Wis(:,(j-1)*K+1:j*K)*His((j-1)*K+1:j*K,:);
        end
end

end
