function [ mm ] = json2moment( arg )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%Poiss
%m=struct('a',1/arg.ulambda,'sa',1/arg.ulambda,'b',1/arg.dlambda,'sb',1/arg.dlambda);

[a,sa]=wblstat(arg.uwb,arg.uwa);
sa=sqrt(sa);
[b,sb]=expstat(1/arg.dlambda);
sb=sqrt(sb);

mm=struct('a',a,'sa',sa,'b',b,'sb',sb);
mm
%return
% weibull, 
[a,sa]=wblstat(arg.uwb,arg.uwa);
sa=sqrt(sa);
[b,sb]=expstat(1/arg.dlambda);
sb=sqrt(sb);
tt=12*30*24*3600;
nn=1.2    ;
mp2std=b/(a+b)*tt + nn*sqrt(tt*(a^2*sb^2+b^2*sa^2)/(a+b)^3);
    function y=fitfun(x)
        y=tt*b./(b+1./x)+nn*sqrt(tt*((1./x).^2*sb^2+b^2*(1./x).^2)./(1./x+b).^3) - mp2std;
    end

m=struct('a',a,'sa',sqrt(sa),'b',1/arg.dlambda,'sb',1/arg.dlambda);


lambda=fzero(@fitfun,7/a);
mm=struct('a',1/lambda,'sa',1/lambda,'b',1/arg.dlambda,'sb',1/arg.dlambda);

%% weibull,2 
[a,sa]=wblstat(arg.uwb,arg.uwa);
sa=sqrt(sa);
[b,sb]=expstat(1/arg.dlambda);
sb=sqrt(sb);

m=struct('a',a,'sa',sa,'b',b,'sb',sb);
%% downtime wszystkie poza Pareto
% Riozklady sa robione tak, ze maja identyczne wariacje, wiec wystarczy
% policzyc dla jednego


% a=1/arg.ulambda;
% sa=1/arg.ulambda;
% %[b,sb]= gpstat(1/arg.dpa,arg.dpb/arg.dpa,arg.dpb);
% [b,sb]= wblstat(arg.dwb,arg.dwa);
% sb=sqrt(sb);
% tt=12*30*24*3600;
% nn=3;
% mp2std=b/(a+b)*tt + nn*sqrt(tt*(a^2*sb^2+b^2*sa^2)/(a+b)^3);
% 
%     function y=fitfun2(x)
%         y=tt*(1./x)./((1./x)+a)+nn*sqrt(tt*((a).^2*(1./x).^2+(1./x).^2*(a).^2)./(a+(1./x)).^3) - mp2std;
%     end
% 
% 
% 
% lambda=fzero(@fitfun2,1/b);
% m=struct('a',a,'sa',sa,'b',1/lambda,'sb',1/lambda);


%% Kwadraty
a=1/arg.ulambda;
sa=1/arg.ulambda;
%[b,sb]= gpstat(1/arg.dpa,arg.dpb/arg.dpa,arg.dpb);
[b,sb]= wblstat(arg.dwb,arg.dwa);
sb=sqrt(sb);

%we wzorach tak jak w mathematice, do funkcji matlaba odwrotnie
m2 = arg.dwb^2*gamma(1+2/arg.dwa);
m4 = arg.dwb^4*gamma(1+4/arg.dwa);

m_var = m4-m2^2;

tt=12*30*24*3600;
nn=0;
mp2std=arg.ulambda*tt*m2 + nn*sqrt(arg.ulambda*tt*m_var +m2^2*(arg.ulambda*tt));

    function y=fitfun3(x)
        fm2=(x.^2)./2;
        fm4=(x.^4)./factorial(4);
        fm_var = fm4-fm2.^2;
        y=arg.ulambda.*tt.*fm2 + nn.*sqrt(arg.ulambda.*tt.*fm_var +fm2.^2.*(arg.ulambda.*tt)) - mp2std;
    end



mf=fzero(@fitfun3,b);
mf=1.4*b;
m=struct('a',a,'sa',sa,'b',mf,'sb',mf);

end

