a=[a,alpha];

X=X*diag(demand);
XS = sum(X,2);


vs= quantile(XS,arg);

sv=0;
for i=1:size(X,2)
    sv = sv + quantile(X(:,i),arg);
end

metryka=[metryka,(sv-vs)/vs];