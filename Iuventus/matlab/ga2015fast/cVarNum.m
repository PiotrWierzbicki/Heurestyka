function cVar = cVarNum(Data, alpha)
    X = alpha:0.0001:1;
    Y = quantile(Data,X);
    cVar = trapz(X,Y)./(1-alpha);
end