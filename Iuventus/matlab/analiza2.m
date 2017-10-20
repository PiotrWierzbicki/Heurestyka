%%start
clear
clc
close all
%% rozklad wykladniczy
load wyniki\WSaExpGER.mat
fileName='wykladniczy'
X=X*diag(demand);
XS = sum(X,2);
argumenty=linspace(0.7,0.99,40);

[f]= quantile(XS,argumenty);
[fc] = cVarNum(XS ,argumenty);


h=figure
plot(argumenty,f,'r','LineWidth',3)
hold on


ff=zeros(size(f));
ffc = zeros(size(fc));

for i=1:size(X,2)
    [f1]= quantile(X(:,i),argumenty);
    [f1c] = cVarNum(X(:,i), argumenty);
    ff=ff+f1;
    ffc = ffc + f1c;
end

plot(argumenty,ff,'g');
%semilogy(argumenty,ff,'g');
hold off
title(sprintf('VaR Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));
legend('var of sum', 'sum of VaR');

%print(h,'-dpdf',sprintf('%s-var.pdf',fileName));

h=figure
plot(argumenty,fc,'r','LineWidth',3)
%semilogy(argumenty,fc,'r','LineWidth',3)
hold on
plot(argumenty,ffc,'g');
%semilogy(argumenty,ffc,'g');
hold off
title(sprintf('CVaR Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));
legend('CVaR of sum', 'sum of CVaR');
%print(h,'-dpdf',sprintf('%s-cvar.pdf',fileName));

h=figure
%hist(X(:),100);
[yy xx] = hist(XS,1000);
plot(xx,yy,'LineWidth',2);
title(sprintf('Hist Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));

data=[argumenty;f;fc;ff;ffc]';
save -ASCII pt/exp.txt data
data=[xx;yy]';
save -ASCII pt/exp_hist.txt data
%% typowy pareto

load wyniki\WSa2.3GER.mat
fileName='wykladniczy'
X=X*diag(demand);
XS = sum(X,2);
argumenty=linspace(0.7,0.99,40);

[f]= quantile(XS,argumenty);
[fc] = cVarNum(XS ,argumenty);


h=figure
plot(argumenty,f,'r','LineWidth',3)
hold on


ff=zeros(size(f));
ffc = zeros(size(fc));

for i=1:size(X,2)
    [f1]= quantile(X(:,i),argumenty);
    [f1c] = cVarNum(X(:,i), argumenty);
    ff=ff+f1;
    ffc = ffc + f1c;
end

plot(argumenty,ff,'g');
%semilogy(argumenty,ff,'g');
hold off
title(sprintf('VaR Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));
legend('var of sum', 'sum of VaR');

%print(h,'-dpdf',sprintf('%s-var.pdf',fileName));

h=figure
plot(argumenty,fc,'r','LineWidth',3)
%semilogy(argumenty,fc,'r','LineWidth',3)
hold on
plot(argumenty,ffc,'g');
%semilogy(argumenty,ffc,'g');
hold off
title(sprintf('CVaR Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));
legend('CVaR of sum', 'sum of CVaR');
%print(h,'-dpdf',sprintf('%s-cvar.pdf',fileName));

h=figure
%hist(X(:),100);
[yy xx] = hist(XS,1000);
plot(xx,yy,'LineWidth',2);
title(sprintf('Hist Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));

data=[argumenty;f;fc;ff;ffc]';
save -ASCII pt/paretor.txt data
data=[xx;yy]';
save -ASCII pt/pareto_hist.txt data

%% jeszcze dobry pareto

load wyniki\WSa1.2GER.mat
fileName='wykladniczy'
X=X*diag(demand);
XS = sum(X,2);
argumenty=linspace(0.7,0.99,40);

[f]= quantile(XS,argumenty);
[fc] = cVarNum(XS ,argumenty);


h=figure
plot(argumenty,f,'r','LineWidth',3)
hold on


ff=zeros(size(f));
ffc = zeros(size(fc));

for i=1:size(X,2)
    [f1]= quantile(X(:,i),argumenty);
    [f1c] = cVarNum(X(:,i), argumenty);
    ff=ff+f1;
    ffc = ffc + f1c;
end

plot(argumenty,ff,'g');
%semilogy(argumenty,ff,'g');
hold off
title(sprintf('VaR Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));
legend('var of sum', 'sum of VaR');

%print(h,'-dpdf',sprintf('%s-var.pdf',fileName));

h=figure
plot(argumenty,fc,'r','LineWidth',3)
%semilogy(argumenty,fc,'r','LineWidth',3)
hold on
plot(argumenty,ffc,'g');
%semilogy(argumenty,ffc,'g');
hold off
title(sprintf('CVaR Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));
legend('CVaR of sum', 'sum of CVaR');
%print(h,'-dpdf',sprintf('%s-cvar.pdf',fileName));

h=figure
%hist(X(:),100);
[yy xx] = hist(XS,1000);
plot(xx,yy,'LineWidth',2);
title(sprintf('Hist Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));

data=[argumenty;f;fc;ff;ffc]';
save -ASCII pt/okparetor.txt data
data=[xx;yy]';
save -ASCII pt/okpareto_hist.txt data

%% zly pareto

load wyniki\WSa0.8GER.mat
fileName='wykladniczy'
X=X*diag(demand);
XS = sum(X,2);
argumenty=linspace(0.7,0.99,40);

[f]= quantile(XS,argumenty);
[fc] = cVarNum(XS ,argumenty);


h=figure
plot(argumenty,f,'r','LineWidth',3)
hold on


ff=zeros(size(f));
ffc = zeros(size(fc));

for i=1:size(X,2)
    [f1]= quantile(X(:,i),argumenty);
    [f1c] = cVarNum(X(:,i), argumenty);
    ff=ff+f1;
    ffc = ffc + f1c;
end

plot(argumenty,ff,'g');
%semilogy(argumenty,ff,'g');
hold off
title(sprintf('VaR Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));
legend('var of sum', 'sum of VaR');

%print(h,'-dpdf',sprintf('%s-var.pdf',fileName));

h=figure
plot(argumenty,fc,'r','LineWidth',3)
%semilogy(argumenty,fc,'r','LineWidth',3)
hold on
plot(argumenty,ffc,'g');
%semilogy(argumenty,ffc,'g');
hold off
title(sprintf('CVaR Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));
legend('CVaR of sum', 'sum of CVaR');
%print(h,'-dpdf',sprintf('%s-cvar.pdf',fileName));

h=figure
%hist(X(:),100);
[yy xx] = hist(XS,1000);
plot(xx,yy,'LineWidth',2);
title(sprintf('Hist Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));

data=[argumenty;f;fc;ff;ffc]';
save -ASCII pt/badparetor.txt data
data=[xx;yy]';
save -ASCII pt/badpareto_hist.txt data