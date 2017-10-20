%jeden komponen
%http://sndlib.zib.de/home.action
tic 

Cx={};
tmax=12*30*24*3600;%rok
%tmax=2*12*30*24*3600;%rok
%tmax=10000;
slacomp={...
    [1,2,3,4],...
    [1,5,6],...
    [2,3,1,4],...
    [5,6],...
    [6,7,1]...
    [8,9]...
    };
% slacomp={...
%     [1],...
%     };
load sieci/slacomp.mat
%load siecinobel-us/slacomp.mat
% to jest do testow
%
% slacomp={...
%     [1,2,3,4],...
%     [1,2,5,6],...
%     };
% 
% slacomp={...
%     [1,2,3],...
%     [1,3,6],...
%     [1,4,5,6],...
%     [4,5,6],...
%     [1,2,5,6],...
%     };
% 
% demand=[1;1;1;1;1];
% params=params([1:3,41,42,43]);
% 

% slacomp={...
%     [1,2],...
%     [2,3],...
%     };
% 
% demand=[1;1];
% params=params([1:3]);

Ncomp = max(cellfun(@(x) max(x),slacomp));
N=100000;
%N=10000;
%N=10000;
%N=100
Nsla=length(slacomp);
X=zeros(N,Nsla);

mode='2';




% parametry z Kuusela i Norros
% router : wykladniczy o sredniej lambd=3.14e6 s = 872h
%topoPlot(slacomp)
%% zmienne ze srodowiska

global lambdar;
global alpha;
global betam;

lambdar=str2double(getenv('LAMBDAR'));
alpha=str2double(getenv('ALPHA'));
betam=str2double(getenv('BETAM'));
plik=getenv('PLIK');

%%

for i=1:N
    [y]=onesim( params,Ncomp,tmax);
    t=y(:,1);
    for k=1:Nsla
        idx=sum(y(:,slacomp{k}+1),2)>0; %+1 bo czasy w 1 kolumnie
        idx2=find(idx==0);
        dt=t(idx2(2:end))-t(idx2(1:end-1)+1);
        X(i,k)=compensationPolicy(dt,tmax,'cptime');
    end
    i
end
X=X*diag(demand);
corsum=corr(X)
%save corsum.mat corsum
save X100kfinalgerpol1.mat X

XS = sum(X,2);


%%
close all

argumenty=0.8:0.01:0.99;
argumenty=[0.9, 0.95, 0.99, 0.999];

N=100;
[f]= quantile(sum(X,2),argumenty);
figure
plot(argumenty,f,'r','LineWidth',3)
hold on


% f2=norminv(argumenty,mean(XS), std(XS));
% plot(argumenty,f2,'c');

%xx=-10:0.1:10;
ff=zeros(size(f));

for i=1:size(X,2)
    [f1]= quantile(X(:,i),argumenty);
    ff=ff+f1;
end

plot(argumenty,ff,'g');


%% teoria z tacasa


momenty=cellfun(@onecomp,params);

srednie=zeros(1, Nsla);
kovariancje=zeros(Nsla, Nsla);

for i=1:Nsla
    msla = momenty(slacomp{i});
   
    x=evarmarkov(msla);
    srednie(i)= tmax*x.b/(x.a+x.b);
    kovariancje(i,i)= tmax*(x.a^2*x.sb^2+x.b^2*x.sa^2)/(x.a+x.b)^3;
end

for i=1:Nsla
    for j=1:Nsla
        wspolne = intersect(slacomp{i}, slacomp{j});
        if i ~= j
            
            if ~isempty(wspolne)
                mm=momenty(wspolne);
                x=evarmarkov(mm);
                kovariancje(i,j) = tmax*(x.a^2*x.sb^2+x.b^2*x.sa^2)/(x.a+x.b)^3;
            end
        end
    end
end

%sredniasumy = sum(srednie);
%varsumy=sum(sum(kovariancje));

sredniasumy = srednie*demand;
varsumy=demand'*kovariancje*demand;

% sredniasumy = mean(XS);
% varsumy=var(XS);


% kwantyle=norminv(argumenty,sredniasumy, sqrt(varsumy));
% plot(argumenty,kwantyle,'black');

%gamma: srednia = a*b,var=a*b^2 > b=var/mean
gammab=varsumy/sredniasumy;
gammaa=sredniasumy/gammab;
pd = makedist('Gamma','a',gammaa,'b',gammab);
kwantyle2=pd.icdf(argumenty);
plot(argumenty,kwantyle2,'black:','LineWidth',3);

legend('kwantyl sumy(e)','suma kwantyli(e)','Ograniczenie analityczne Gamma', 'Location','NorthWest');
data=[1:4;f;ff;kwantyle2]'
save -ASCII datacptime.txt data
%% Cvar, polityka1
figure;

cvarsumy=zeros(size(argumenty));

for i=1:length(argumenty)
    cvarsumy(i)=cVarNum(XS,argumenty(i));
end

cvary=zeros(Nsla,length(argumenty));

for j=1:Nsla
    for i=1:length(argumenty)
        cvary(j,i) = cVarNum(X(:,j),argumenty(i));
    end
end
sumacvar = sum(cvary);


Tcvarsumy=zeros(size(argumenty));

for i=1:length(argumenty)
    Tcvarsumy(i)=gamma_cVar(argumenty(i), gammaa, gammab);
end
plot(argumenty, sumacvar,'green');

hold on
plot(argumenty, cvarsumy,'r','LineWidth',3);
plot(argumenty, Tcvarsumy,'black:','LineWidth',3);
legend('suma cvarow','cvar sumy','Ograniczenie analityczne Gamma', 'Location','NorthWest');

%export
data=[1:4;sumacvar;cvarsumy;Tcvarsumy]'
save -ASCII dataCVARcptime.txt data


