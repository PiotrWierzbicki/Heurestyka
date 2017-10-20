%%
close all

argumenty=0.8:0.01:0.99;
argumenty=[0.8,0.9, 0.95, 0.99, 0.999];
argumenty=[0.9, 0.95, 0.99, 0.999];

%XS=sum(X,2);
XS=X*demand;
XW=X*diag(demand);

N=100;
[f]= quantile(XS,argumenty);
figure
plot(argumenty,f,'r','LineWidth',3)
hold on


f2=norminv(argumenty,mean(XS), std(XS));
plot(argumenty,f2,'c');

%xx=-10:0.1:10;
ff=zeros(size(f));

for i=1:size(X,2)
    [f1]= quantile(XW(:,i),argumenty);
    ff=ff+f1;
end

plot(argumenty,ff,'g');
