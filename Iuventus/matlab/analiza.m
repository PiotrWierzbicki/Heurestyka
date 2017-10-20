clear
clc
qq=boolean(paramFromEnv('EXIT_MATLAB',0));
fileName=paramFromEnv('FILE_NAME','plik2.mat');
load(fileName);

XS = sum(X,2);

close all

argumenty=0.8:0.01:0.99;
%argumenty=[0.8,0.9, 0.95, 0.99, 0.999];
argumenty=linspace(0.7,0.99,40);

%N=100;
[f]= quantile(sum(X,2),argumenty);
[fc] = cVarNum(sum(X,2),argumenty);


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

print(h,'-dpdf',sprintf('%s-var.pdf',fileName));

h=figure
plot(argumenty,fc,'r','LineWidth',3)
%semilogy(argumenty,fc,'r','LineWidth',3)
hold on
plot(argumenty,ffc,'g');
%semilogy(argumenty,ffc,'g');
hold off
title(sprintf('CVaR Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));
legend('CVaR of sum', 'sum of CVaR');
print(h,'-dpdf',sprintf('%s-cvar.pdf',fileName));
%X=X*diag(demand);

%%

%%% histogram kar %%%
h=figure
%hist(X(:),100);
[yy xx] = hist(X*demand,1000);
plot(xx,yy,'LineWidth',2);
title(sprintf('Hist Pareto %s, l=%f,a=%f,b=%f',fileName,lambdar,alpha,betam));
print(h,'-dpdf',sprintf('%s-hist.pdf',fileName));

if qq
    exit
end

%% zapis do csv %%

% X1 = [argumenty; f];
% csvwrite('var_sumy.csv',X1);
% 
% X2 = [argumenty; ff];
% csvwrite('suma_var??w.csv',X2);
% 
% X3 = [argumenty; fc];
% csvwrite('cvar_sumy.csv',X3);
% 
% X4 = [argumenty; ffc];
% csvwrite('suma_cvar??w.csv',X4);
