function [ x ] = evarmarkov2( momenty, thr )

Q=createQ(momenty);
size(Q)
%przyblizenie 2
dQ=-diag(Q);
P = bsxfun(@ldivide,dQ, Q) + speye(size(Q));
Puo=P(2:end,1);
Plo=P(1,2:end);
% P = P(2:end,2:end);
% Lp=diag(-1./dQ(2:end));
% Lb=diag(2./dQ(2:end).^2);
% 
% m1=-(Plo*Lp*Puo + Plo*Lp*P*P*Puo + Plo*P*Lp*P*Puo + Plo*P*P*Lp*Puo);
% m2= Plo*Lb*Puo + Plo*Lb*P*P*Puo + Plo*P*P*Lb*Puo + 2*Plo*P*Lp*P*Lp*Puo + ...
%     2*Plo*Lp*P*Lp*P*Puo + 2*Plo*Lp*P*P*Lp*Puo + Plo*P*Lb*P*Puo;

% strona 211 Markocv...
T=Q(2:end,2:end);
m1=full( Plo*(T^2\Q(2:end,1)) );
%Plo*inv(T*T)*Q(2:end,1);
%Tak jest efektywniej
m2=full( -2*Plo*(T^3\Q(2:end,1)) );




x=struct();
x.en = sum(arrayfun(@(x) 1./x.a ,momenty));
x.vn=sum(arrayfun(@(x) x.sa^2./x.a^3 ,momenty));

x.b = m1+thr;
x.b = m1;
x.sb = sqrt(m2-m1^2);

return

x=struct();
x.a=1/sum(Q(1,2:end));
x.sa=x.a; % bo wykladniczy

mQ = -diag(Q);
Puni = Q./repmat(mQ,1,size(Q,1));
Puni = Puni - diag(diag(Puni));


Pf = Puni(2:end,2:end);
nu=Puni(1,2:end);
nu=nu/sum(nu);
Pout=Puni(2:end,1);


naprawy=mQ(2:end);

lap= diag(naprawy./(ones(size(naprawy))*sym('s') + naprawy));
pochodna=diff(nu*lap*Pout + nu*(lap*Pf)^2*lap*Pout + nu*(lap*Pf)^4*lap*Pout );
% subs(pochodna, 's',0)
x.b=-double(subs(pochodna, 's',0));
pochodna = diff(pochodna);
moment2=double(subs(pochodna, 's',0));
x.sb=sqrt(moment2-x.b^2);

end


function Q=createQ(moments)
%javaclasspath ../../java/NetworkMarkov/dist/NetworkMarkov.jar
n=length(moments);
k=3;
if k>n
    k=n;
end
s=networkmarkov.NetworkMarkov(n,k);
lambdas=arrayfun(@(arg) 1/arg.a,moments);
mus=arrayfun(@(arg) 1/arg.b,moments);

x=s.makeQ(lambdas, mus);

d=sum(arrayfun(@(arg) nchoosek(n,arg),0:k));
Q=sparse(double(x.iidx)+1,double(x.jidx)+1,x.values,d,d);
Q=Q-diag(sum(Q,2));
end
