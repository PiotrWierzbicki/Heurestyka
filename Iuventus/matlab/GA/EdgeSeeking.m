clear
clc
close all


RiskMeasure = paramFromEnv('RiskM','mean');
Policy = paramFromEnv('Policy','cptime');
Net = paramFromEnv('Nets','US');
OptimF = paramFromEnv('OptimF',4);
Weight = paramFromEnv('Weight',16000);
CrashData = paramFromEnv('CrashData','../../symulacje/optim-us-sbpp5.mat');
NetData = paramFromEnv('NetData','../../sieci/slacomp-us.mat');
Pl = paramFromEnv('Pl',1);
StartConf = 5;

load(CrashData);
load(NetData);


    
%%
PopulationSize = 320;
EliteCount = 310;
nParents = 310;

alphaV = 0.95;
betaV = 0.005;

if(StartConf==1)
    beta = 0.001;
    PopulationSize = 320;
    EliteCount = 310;
    nParents = 310;
elseif(StartConf==2)
    beta = 0.02;
    PopulationSize = 120;
    EliteCount = 110;
    nParents = 110;
elseif(StartConf==3)
    beta = 0.02;
    PopulationSize = 120;
    EliteCount = 110;
    nParents = 110;
elseif(StartConf==4)
    beta = 0.001;
    PopulationSize = 320;
    EliteCount = 310;
    nParents = 310;
end

if(strcmp(RiskMeasure,'mean'))
    maxIter = 200000;
    maxConstantIter = 200000;
else
    maxIter = 200000;
    maxConstantIter = 200000;    
end

minIter = 1;

funs = [{@FitnessFun},{@FitnessFun2},{@FitnessFun3},{@FitnessFun4},{@FitnessFun5}];

s1 = CrashData;
s2 = NetData;


%%
X = cellfun(@(arg) arg*diag(demand),X,'UniformOutput',0);

%% remove routers
slacomp=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp,'UniformOutput', false);
slacomp2=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp2,'UniformOutput', false);

for i=1:length(alternativeslacomp)
    alternativeslacomp{i}=cellfun(@(arg) linksOnly(arg,noOfNodes),alternativeslacomp{i},'UniformOutput', false);
end

cap = zeros(size(cap)) + max(GetCapacity(slacomp,cap,demand,noOfNodes));

%%
Xcptime = cell2mat(X(1,:));
Xnfail = cell2mat(X(2,:));

CovXcptime = cov(Xcptime);
CovXnfail = cov(Xnfail);

MeanXcptime = mean(Xcptime);
MeanXnfail = mean(Xnfail);


%%

Data.slacomp = slacomp;
Data.slacomp2 = slacomp2;
Data.alternativeslacomp = alternativeslacomp;
Data.X = X;
Data.CovXcptime = CovXcptime;
Data.MeanXcptime = MeanXcptime;
Data.CovXnfail = CovXnfail;
Data.MeanXnfail = MeanXnfail;
Data.demand = demand;
Data.cap = cap;
Data.noOfNodes = noOfNodes;

mm = size(slacomp,2);


r0=zeros(4,mm);
r0(1,:) = 1;
P0{1}.DNA = bsxfun(@eq,r0,max(r0));
[~, ~, R0] = FitnessFun(P0{1},Data,Weight,alphaV,0,Policy,RiskMeasure);

for ii=1:4
    r0=zeros(4,mm);
    r0(1,:) = 1;
    P0{ii}.DNA = bsxfun(@eq,r0,max(r0));
    [P0{ii}.F, P0{ii}.C, P0{ii}.V] = funs{OptimF}(P0{ii},Data,Weight,alphaV,R0,Policy,RiskMeasure);
end

% [~, ~, R0] = FitnessFun(P0{1},Data,Weight,alphaV,R0,Policy,RiskMeasure);


CC = [];
VV = [];
CC0 = zeros(1,PopulationSize);
VV0 = zeros(1,PopulationSize);

for i=1:PopulationSize
%    ri = StartConf;
    ri = randi(4);
%      r=rand(4,mm);
     r=zeros(4,mm);
     r(ri,:) = 1;
     
%     if(StartConf==5)
%         r=rand(4,mm);
%     end
        
     
    Pop{i}.DNA = bsxfun(@eq,r,max(r));
    [Pop{i}.F, Pop{i}.C, Pop{i}.V] = funs{OptimF}(Pop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure);
    CC0(i) = Pop{i}.C;
    VV0(i) = Pop{i}.V;
end


for i=1:4
    r = zeros(4,mm);
    r(i,:) = 1;
    Pop2{i}.DNA = bsxfun(@eq,r,max(r));
    [Pop2{i}.F, Pop2{i}.C, Pop2{i}.V] = funs{OptimF}(Pop2{i},Data,Weight,alphaV,R0,Policy,RiskMeasure);
    CC1(i) = Pop2{i}.C;
    VV1(i) = Pop2{i}.V;
end

if(Pl)
    plot(CC1,VV1,'black.', 'MarkerSize', 20);
%    hold on
end
% 
% plot(CC0,VV0,'r.','MarkerSize',4);
% hold on

% for i=1:4
%     r = zeros(4,mm);
%     r(i,:) = 1;
%     Pop{i}.DNA = bsxfun(@eq,r,max(r));
%     [Pop{i}.F, Pop{i}.C, Pop{i}.V] = funs{OptimF}(Pop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure);
%     CC0(i) = Pop{i}.C;
%     VV0(i) = Pop{i}.V;
%     Pop{i}.F = funs{5}(Pop,CC0,VV0,i);
% end

j = 1;
num = 0;

tic
while (num<=maxConstantIter && j<=maxIter)

    Surv = GA_Select(Pop,PopulationSize,EliteCount,nParents);  
    NewPop = GA_Crossover(Surv,PopulationSize,EliteCount,Data);
    NewPop = GA_Mutation(NewPop,nParents,betaV);

    for i=EliteCount+1:PopulationSize
        [~, NewPop{i}.C, NewPop{i}.V] = funs{OptimF}(NewPop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure);
    end

%         for i=1:PopulationSize
%             tmpF(i) = Pop{i}.F;
%         end

    for i=1:PopulationSize
%        tmpF(i) = NewPop{i}.F;
        tmpC(i) = NewPop{i}.C;
        tmpV(i) = NewPop{i}.V;
    end

    CC = [CC tmpC];
    VV = [VV tmpV];
    
%     dat = [tmpC; tmpV]';
%     N = length(tmpC);
%     d2=zeros(N,1);
%     for i=1:N
%         d2(i)= sum(all(bsxfun(@lt,dat,dat(i,:)),2));
%     end
    
    for i=1:PopulationSize
         NewPop{i}.F = funs{5}(NewPop,tmpC,tmpV,i,R0);
%        NewPop{i}.F = 1/(d2(i) + 0.1);
    end
    
    
    for i=1:PopulationSize
        tmpF(i) = NewPop{i}.F;
    end
    
    if(Pl)
        plot(tmpC,tmpV,'.','MarkerSize',4);
        hold on
        pause(0.01)
    end

    meann(j) = mean(tmpF);
    minn(j) = min(tmpF);
    maxx(j) = max(tmpF);

    Pop = NewPop;

    if(j > minIter && maxx(j)==maxx(j-1))
        num = num + 1;
    elseif(j > minIter && maxx(j)>maxx(j-1))
        num = 0;
    end

    j = j + 1;
    disp(j);
    toc
end

% s = ['Edge_', RiskMeasure, '_', Policy, '_', Net, '_', num2str(OptimF), '_', num2str(Weight), '_', num2str(StartConf), '.mat'];
% save(s, 'NewPop', 'P0', 'maxx', 'betaV', 'EliteCount', 'nParents', 'PopulationSize', 'CC', 'VV', 'CC0', 'VV0','RiskMeasure', 'Policy','Net', 'OptimF','Weight');
% 
% %close all
% % 
% exit


%%
% mm = size(slacomp,2);
% 
% for n=1:2000
%     disp(n)
%     r=rand(4,mm);
%     DNA = bsxfun(@eq,r,max(r));
% 
%     NDNA = DNA';
%     NDNA = NDNA(:);
% 
%     VAR = (MeanXcptime*NDNA + norminv(0.95)*sqrt(NDNA'*CovXcptime*NDNA));
%     %VAR = (sqrt(NDNA'*CovXcptime*NDNA));
%     
%     XT = zeros(100000,1);
%     for i=1:mm
%         tmp =DNA(:,i);
%         XT = XT + X{1,tmp}(:,i);
%     end
%     R(n) = quantile(XT,0.95);
%     S(n) = std(XT);
%     M(n) = mean(XT);
%     EstS(n) = VAR;
% end
% 
% %%
% % for n=1:1
% %     disp(n)
% %     mm = size(slacomp,2);
% %     r=rand(4,mm);
% %     DNA = bsxfun(@eq,r,max(r));
% %     
% %     XT = zeros(100000,1);
% %     for i=1:mm
% %         tmp =DNA(:,i);
% %         XT = XT + X{1,tmp}(:,i);
% %     end
% %     R94(n) = quantile(XT,0.94);
% %     S94(n) = mean(XT) + std(XT);
% % 
% %     R95(n) = quantile(XT,0.95);
% %     S95(n) = mean(XT) + std(XT);   
% %     
% %     R96(n) = quantile(XT,0.96);
% %     S96(n) = mean(XT) + std(XT);
% % end
% 
% 
%%
% 
% for kk=1:40
%     ff(kk) = FitnessFun(NewPop{kk},Data,Weight,alphaV,0,policy,RiskMeasure);
%     ff0(kk) = NewPop{kk}.F;
% end
