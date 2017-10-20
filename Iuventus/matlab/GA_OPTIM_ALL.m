clc

disp(RiskMeasure)
disp(Policy)
disp(Net)
disp(OptimF)
disp(Weight)

% CrashData = paramFromEnv('CrashData','optim-germanyi-sbpp5.mat');
% NetData = paramFromEnv('NetData','slacomp-germany.mat');

PopulationSize = 40;
EliteCount = 10;

alphaV = 0.95;
betaV = 0.06;

maxIter = 5000;
minIter = 1;
maxConstantIter = 500;

funs = [{@FitnessFun},{@FitnessFun2},{@FitnessFun3}];

s1 = CrashData;
s2 = NetData;

helper_optim

Data.slacomp = slacomp;
Data.slacomp2 = slacomp2;
Data.alternativeslacomp = alternativeslacomp;
Data.X = X;
Data.demand = demand;
Data.cap = cap;
Data.noOfNodes = noOfNodes;

mm = size(slacomp,2);
 
r0=zeros(4,mm);
r0(1,:) = 1;
P0.DNA = bsxfun(@eq,r0,max(r0));
[~, ~, R0] = FitnessFun(P0,Data,Weight,alphaV,0,Policy,RiskMeasure);  

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
while (num<=maxConstantIter && j<=maxIter)

    Surv = GA_Select(Pop,PopulationSize,EliteCount);  
    NewPop = GA_Crossover(Surv,PopulationSize,EliteCount,Data);
    NewPop = GA_Mutation(NewPop,EliteCount,betaV);

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

    meann(j) = mean(tmpF);
    minn(j) = min(tmpF);

    min_a = (min(tmpF));
    mean_a = (mean(tmpF));


    Pop = NewPop;

    if(j > minIter && minn(j)==minn(j-1))
        num = num + 1;
    elseif(j > minIter && minn(j)<minn(j-1))
        num = 0;
    end

    j = j + 1;
    disp(j);
end

s = [RiskMeasure, '_', Policy, '_', Net, '_', num2str(OptimF), '_', num2str(Weight), '.mat'];
save(s, 'NewPop', 'minn', 'betaV', 'EliteCount', 'PopulationSize', 'CC', 'VV', 'CC0', 'VV0','RiskMeasure', 'Policy','Net', 'OptimF','Weight');

exit
