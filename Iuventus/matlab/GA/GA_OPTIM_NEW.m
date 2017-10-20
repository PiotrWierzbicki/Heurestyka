RiskMeasure = paramFromEnv('RiskM','cVar');
Policy = paramFromEnv('Policy','cptime');
Net = paramFromEnv('Nets','GER');
OptimF = paramFromEnv('OptimF',2);
Weight = paramFromEnv('Weight',32000);
CrashData = paramFromEnv('CrashData','symulacje/optim-germanyi-sbpp5.mat');
NetData = paramFromEnv('NetData','sieci/slacomp-germany.mat');

%%

load(CrashData);
load(NetData);
clear X;


%%
PopulationSize = 40;
EliteCount = 4;
nParents = 20;

alphaV = 0.95;
betaV = 0.01;

maxIter = 5000;
%maxIter = 1;
minIter = 1;
maxConstantIter = 500;

funs = [{@FitnessFun},{@FitnessFun2},{@FitnessFun3},{@FitnessFun4}];

s1 = CrashData;
s2 = NetData;


%%
%X = cellfun(@(arg) arg*diag(demand),X,'UniformOutput',0);

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

P0={};

r0=zeros(4,mm);
r0(1,:) = 1;
P0{1}.DNA = bsxfun(@eq,r0,max(r0));
[~, ~, R0] = FitnessFun(P0{1},Data,Weight,alphaV,0,Policy,RiskMeasure);

for ii=1:4
    r0=zeros(4,mm);
    r0(ii,:) = 1;
    P0{ii}.DNA = bsxfun(@eq,r0,max(r0));
    [P0{ii}.F, P0{ii}.C, P0{ii}.V] = funs{OptimF}(P0{ii},Data,Weight,alphaV,R0,Policy,RiskMeasure);
    plot(P0{ii}.C,P0{ii}.V,'black.', 'MarkerSize', 20);
    hold on
end



% [~, ~, R0] = FitnessFun(P0{1},Data,Weight,alphaV,R0,Policy,RiskMeasure);


CC = [];
VV = [];
CC0 = zeros(1,PopulationSize);
VV0 = zeros(1,PopulationSize);

for i=1:PopulationSize
    r=rand(4,mm);
    Pop{i}.DNA = bsxfun(@eq,r,max(r));
    [Pop{i}.F, Pop{i}.C, Pop{i}.V] = funs{OptimF}(Pop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure);
    CC0(i) = Pop{i}.C;
    VV0(i) = Pop{i}.V;
end

% for i=1:4
%     r = zeros(4,mm);
%     r(i,:) = 1;
%     Pop{i}.DNA = bsxfun(@eq,r,max(r));
%     [Pop{i}.F, Pop{i}.C, Pop{i}.V] = funs{OptimF}(Pop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure);
%     CC0(i) = Pop{i}.C;
%     VV0(i) = Pop{i}.V;
% end

j = 1;
num = 0;

tic
while (num<=maxConstantIter && j<=maxIter)

    Surv = GA_Select(Pop,PopulationSize,EliteCount,nParents);  
    NewPop = GA_Crossover(Surv,PopulationSize,EliteCount,Data);
    NewPop = GA_Mutation(NewPop,nParents,betaV);

    for i=1:PopulationSize
        [NewPop{i}.F, NewPop{i}.C, NewPop{i}.V] = funs{OptimF}(NewPop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure);
    end
    


%         for i=1:PopulationSize
%             tmpF(i) = Pop{i}.F;
%         end

    for i=1:PopulationSize
        tmpF(i) = NewPop{i}.F;
        tmpC(i) = NewPop{i}.C;
        tmpV(i) = NewPop{i}.V;
    end

    CC = [CC tmpC];
    VV = [VV tmpV];
    
    plot(CC,VV,'.');
    hold on
    pause(0.01)

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

% s = ['wyniki/',RiskMeasure, '_', Policy, '_', Net, '_', num2str(OptimF), '_', num2str(Weight), '.mat'];
% save(s, 'NewPop', 'P0', 'maxx', 'betaV', 'EliteCount', 'nParents', 'PopulationSize', 'CC', 'VV', 'CC0', 'VV0','RiskMeasure', 'Policy','Net', 'OptimF','Weight');
% 
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
