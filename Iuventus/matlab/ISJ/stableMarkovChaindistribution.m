function P = stableMarkovChaindistribution( T )
%STABLEMARKOVCHAINDISTRIBUTION Summary of this function goes here
%   Liczy rozk�ad stacjonarny lancucha markowa

m=size(T);
m=m(1);
P=[zeros(1,m) 1 ]/[T-eye(m) ones(m,1)];

end

