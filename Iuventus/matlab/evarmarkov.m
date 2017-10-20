function [ x ] = evarmarkov( momenty )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Q=[-1/lambdas(1),1/lambdas(1);1/mus(1),-1/mus(1)];

%przyblizenie 
% x=struct();
% x.a = 1/sum(arrayfun(@(x) 1./x.a ,momenty));
% x.sa=x.a;
% wagi=arrayfun(@(x) 1./x.a ,momenty);
% wagi=wagi/sum(wagi);
% 
% x.b = arrayfun(@(x) x.b ,momenty)*wagi';
% %http://en.wikipedia.org/wiki/Law_of_total_variance
% x.sb = sqrt(arrayfun(@(x) x.sb^2 ,momenty)*wagi' + (arrayfun(@(x) x.b^2 ,momenty)*wagi' - x.b^2 ));
% return

Q=[-1/momenty(1).a,1/momenty(1).a;1/momenty(1).b,-1/momenty(1).b];
l=length(momenty);
for i=2:l
     Q=kronsum(Q,[-1/momenty(i).a,1/momenty(i).a;1/momenty(i).b,-1/momenty(i).b]);
end


%przyblizenie 2
dQ=-diag(Q);
P = bsxfun(@ldivide,dQ, Q) + speye(size(Q));
Puo=P(2:end,1);
Plo=P(1,2:end);
P = P(2:end,2:end);
Lp=diag(-1./dQ(2:end));
Lb=diag(2./dQ(2:end).^2);

m1=-(Plo*Lp*Puo + Plo*Lp*P*P*Puo + Plo*P*Lp*P*Puo + Plo*P*P*Lp*Puo);
m2= Plo*Lb*Puo + Plo*Lb*P*P*Puo + Plo*P*P*Lb*Puo + 2*Plo*P*Lp*P*Lp*Puo + ...
    2*Plo*Lp*P*Lp*P*Puo + 2*Plo*Lp*P*P*Lp*Puo + Plo*P*Lb*P*Puo;


x=struct();
x.a = 1/sum(arrayfun(@(x) 1./x.a ,momenty));
x.sa=x.a;

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

