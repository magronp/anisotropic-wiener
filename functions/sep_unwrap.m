function [Se,mu] = sep_unwrap(X,v,nu,hop,UN)

[F,T,J] = size(v);

if nargin<5
    UN = zeros(J,T);
end

% Initialization
mu = repmat(angle(X),[1 1 J]);

% Loop over time frames
for t=2:T
    if (sum(UN(:,t))<J) % if the current frame is onset for all sources, do nothin
        % Initialisation : if onset frame, do nothing, if not, unwrapping
        for j=1:J
             if (UN(j,t)==0) % non-onset frame for source k
                 mu(:,t,j) = mu(:,t-1,j)+2*pi*hop*nu(:,t,j);
             end
        end
    end
end

Se = sqrt(v) .* exp(1i * mu);

end
