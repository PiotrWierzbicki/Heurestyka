clear java
javaclasspath dist/NetworkMarkov.jar
n=4
k=2;
s=networkmarkov.NetworkMarkov(n,k)
lambdas=1:n
mus=100*lambdas
x=s.makeQ(lambdas, mus);

d=sum(arrayfun(@(arg) nchoosek(n,arg),0:k));
Q=sparse(double(x.iidx)+1,double(x.jidx)+1,x.values,d,d);
%expm(Q);
%%
Q=full(Q);
Q=Q-diag(sum(Q,2))
Q(end,:)=zeros(1,d);
%%
ss=0.000001;

tmp=inv(ss*eye(size(Q))-Q);
tmp*ss;

-tmp*Q*tmp
%%
% size(x.iidx,1)
% 2*sum(arrayfun(@(arg) nchoosek(n,arg),1:k).*(1:k))
% 
% 
% eigs(Q);
% 
% [V,D] = eig(full(Q));
% sum(abs(diag(D))>1)