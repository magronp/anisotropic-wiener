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
end

end
