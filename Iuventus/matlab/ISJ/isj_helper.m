clear
m=matfile('../ograniczenie_workshop/data.mat');
%germanyExpUnprotectedFixedRestartCostExp.txt, 6, 9 
%x=m.data(6,1);
%data=x.data(:,strcmp('UnprotectedFixedRestartCost',x.lbl));
%data=x.data(:,strcmp('DedicatedSnowball',x.lbl));
%data=x.data(:,strcmp('DedicatedLinearCost',x.lbl));

%% germanyExpUnprotectedContExp
% x=m.data(6,1);
% data=x.data(:,strcmp('UnprotectedCont',x.lbl));
% expfilename='germanyExpUnprotectedContExp'


%x=m.data(5,1);
% data=x.data(:,strcmp('UnprotectedCont',x.lbl));
% expfilename='usExpUnprotectedContExp'

% x=m.data(6,1);
% data=x.data(:,strcmp('DedicatedFixedRestartCost',x.lbl));
% expfilename='germanyExpDedicatedFixedRestartCostExp'

% x=m.data(5,1);
% data=x.data(:,strcmp('DedicatedFixedRestartCost',x.lbl));
% expfilename='usExpDedicatedFixedRestartCostExp'

% x=m.data(30,1);
% data=x.data(:,strcmp('UnprotectedFixedRestartCost',x.lbl));
% expfilename='germanyWeibUnprotectedFixedRestartCostExp'

% x=m.data(29,1);
% data=x.data(:,strcmp('UnprotectedFixedRestartCost',x.lbl));
% expfilename='usWeibUnprotectedFixedRestartCostExp'

% x=m.data(29,1);
% data=x.data(:,strcmp('UnprotectedCont',x.lbl));
% expfilename='usWeibUnprotectedContExp'


x=m.data(30,1);
data=x.data(:,strcmp('UnprotectedCont',x.lbl));
expfilename='germanyWeibUnprotectedContExp'


%% parsowanie danych

json=parse_json( fileread(['../ograniczenie_workshop/',x.net]));
%load ..\ograniczenie_workshop\out.mat
%netName=x.net;
%% parsowanie
javaclasspath NetworkMarkov.jar
demands=cellfun(@(arg) arg.demand,json{1}.slas);
%moments=cellfun(@(arg) struct('a',1/arg.ulambda,'sa',1/arg.ulambda,'b',1/arg.dlambda,'sb',1/arg.dlambda),json{1}.components);
moments=cellfun(@json2moment,json{1}.components);
paths=cellfun(@(arg) cell2mat(arg.path),json{1}.slas,'UniformOutput',false);
backupPaths=cellfun(@(arg) cell2mat(arg.backupPath),json{1}.slas,'UniformOutput',false);
Nsla = length(paths);
%Nsla=10;
tmax = 12*30*24*3600;
argumenty=[0.9, 0.95, 0.99, 0.999];


%% Policy

%scale=x.scale;
thr = min([moments.b])* x.scale;
compensation='avail';
compensation='snowball';
compensation='fixedrestart';
compensation='cont';

%% teoria
close all
srednie=zeros(1, Nsla);
kovariancje=zeros(Nsla, Nsla);
ttmax=tmax;
%thr=0;
tic
for i=1:Nsla
    [ esla, varsla ] = slastat( i,paths,moments,tmax,compensation,thr );
    %[ esla, varsla ] = protslastat( i,paths,backupPaths, moments,tmax,compensation,thr );
    srednie(i)= esla;
    kovariancje(i,i)= varsla;
    disp(i)
end

for i=1:Nsla
    for j=i+1:Nsla
        kovariancje(i,j) =  slacov( i, j,paths,moments,tmax,compensation,thr );
        %tic
        %kovariancje(i,j) =  protslacov( i, j,paths,backupPaths,moments,tmax,compensation,thr );
        %toc
    end
    disp(i)
end
toc
if strcmp(compensation,'cont')
    demands=ones(size(demands));
end
kovariancje = kovariancje +kovariancje' -diag(diag(kovariancje));
sredniasumy2 = srednie*demands(1:Nsla)';
varsumy2=demands(1:Nsla)*kovariancje*demands(1:Nsla)';

lnsigma=sqrt(log(varsumy2/sredniasumy2^2+1));
lnmu=log(sredniasumy2)-(lnsigma^2)/2;

pd = makedist('Lognormal','mu',lnmu,'sigma',lnsigma);

kwantyle22=pd.icdf(argumenty);


% idx =  strcmp(netName,out(:,4)) & ...
%     cellfun(@(x)x==scale ,out(:,3)) & ...
%     strcmp('UnprotectedCont',out(:,5));

%strcmp('UnprotectedSnowball',out(:,5));
%strcmp('UnprotectedFixedRestartCost',out(:,5));
% idx =  strcmp(netName,out(:,4)) & ...
%     cellfun(@(x)x==1 ,out(:,3)) & ...
%     strcmp('DedicatedAvail',out(:,5));


%out2=out(idx,:);
figure
hold on
cc=lines(12);
%for i=1:size(out2,1)
%for i=[1:2]
    %plot(out2{i,6},'Color',cc(i,:))
%end
%plot(quantile(data*demands',argumenty));
plot(quantile(sum(data(:,1:Nsla),2),argumenty));
plot(kwantyle22,'Color','Black','LineWidth',2.1);

%plot(out2{1,6},'Color',cc(1,:))

%plot(kwantyle22,'Color','Black','LineWidth',2.1);
%plot(out2{1,7},'Color',cc(2,:))

%legend(strcat(out2(:,1),out2(:,2)))
tmp=[1:length(argumenty);kwantyle22]';
fname=['varTh',expfilename,'.txt'];
save(fullfile('points2',fname),'-ascii','tmp'); 

cvar=arrayfun(@(arg) lognorm_cVar(arg,lnmu,lnsigma), argumenty);
tmp=[1:length(argumenty);cvar]';
fname=['c',fname];
save(fullfile('points2',fname),'-ascii','tmp'); 

%% export

varsumy=quantile(sum(data(:,1:Nsla),2),argumenty);
fname=['varsumy','P',expfilename,'.txt'];
tmp=[1:length(argumenty);varsumy]';
save(fullfile('points2',fname),'-ascii','tmp'); 

sumvar=sum(quantile(data(:,1:Nsla),argumenty),2);
tmp=[1:length(argumenty);sumvar']';
fname=['sumvar','P',expfilename,'.txt'];
save(fullfile('points2',fname),'-ascii','tmp'); 


%cvar=cVarNum(,argumenty);
tmp = sum(data(:,1:Nsla),2);
cvar=arrayfun(@(arg) cVarNum(tmp,arg), argumenty);
tmp=[1:length(argumenty);cvar]';
fname=['cvar','P',expfilename,'.txt'];
save(fullfile('points2',fname),'-ascii','tmp'); 

%% Playground
% 
% %numer=40;
% %numer2=18;
% data=x.data(:,strcmp('UnprotectedCont',x.lbl));
% numer=1;
% numer2=2;
% 
% [ esla, varsla ] = slastat( numer,paths,moments,tmax,'cont',thr )
% mean(data(:,[numer]))
% var(data(:,[numer]))
% 
% slacov( numer, numer2,paths,moments,tmax,'cont',thr )
% cov(data(:,[numer,numer2]))
% 
% wspolne = intersect(paths{numer}, paths{numer2});
% tmp=evarmarkov2(moments(wspolne),thr);
% tmax*(tmp.en*tmp.sb^2+tmp.b^2*tmp.vn)
% 
%% Playground prot
% clc
% data=x.data(:,strcmp('DedicatedSnowball',x.lbl));
% %data=x.data(:,strcmp('DedicatedAvail',x.lbl));
% numer=10;
% numer2=18;
% covsla=protslacov(numer, numer2,paths, backupPaths,moments,tmax ,'snowball',thr)
% cov(data(:,[numer,numer2]))/demands(numer)/demands(numer2)
% 
% [ esla, varsla ] = protslastat( numer,paths, backupPaths,moments,tmax ,'snowball',thr)
% mean(data(:,[numer]))/demands(numer)
% var(data(:,[numer]))/demands(numer)^2

%% przycinanie

