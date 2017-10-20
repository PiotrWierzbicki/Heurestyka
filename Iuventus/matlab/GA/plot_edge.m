clear;
clc;

RiskMeasure = 'mean';
Policy = 'nfail';
Net = 'US';
OptimF = 4;
Weight = 8;


load(['Edge_', RiskMeasure, '_', Policy, '_', Net,'_', num2str(OptimF), '_', num2str(Weight), '_', num2str(1), '.mat']);
% load('Edge_mean_nfail_GER_4_16000_1.mat');
% plot(CC,VV)
plot(CC,VV,'.','MarkerSize',4)
hold on
load(['Edge_', RiskMeasure, '_', Policy, '_', Net,'_', num2str(OptimF), '_', num2str(Weight), '_', num2str(2), '.mat']);
plot(CC,VV,'r.','MarkerSize',4)
hold on
load(['Edge_', RiskMeasure, '_', Policy, '_', Net,'_', num2str(OptimF), '_', num2str(Weight), '_', num2str(3), '.mat']);
plot(CC,VV,'g.','MarkerSize',4)
hold on
load(['Edge_', RiskMeasure, '_', Policy, '_', Net,'_', num2str(OptimF), '_', num2str(Weight), '_', num2str(4), '.mat']);
plot(CC,VV,'r+','MarkerSize',4)
hold on
load(['Edge_', RiskMeasure, '_', Policy, '_', Net,'_', num2str(OptimF), '_', num2str(Weight), '_', num2str(5), '.mat']);
plot(CC,VV,'g+','MarkerSize',4)
hold on




addpath('../../GA/');
alphaV = 0.95;
funs = [{@FitnessFun},{@FitnessFun2},{@FitnessFun3},{@FitnessFun4},{@FitnessFun5}];

if strcmp(Net,'GER')
    CrashData='../../symulacje/optim-germanyi-sbpp5.mat';
    NetData = '../../sieci/slacomp-germany.mat';
else
    CrashData='../../symulacje/optim-us-sbpp5.mat';
    NetData = '../../sieci/slacomp-us.mat';
end

load(CrashData);
load(NetData);

X = cellfun(@(arg) arg*diag(demand),X,'UniformOutput',0);

slacomp=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp,'UniformOutput', false);
slacomp2=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp2,'UniformOutput', false);

for i=1:length(alternativeslacomp)
    alternativeslacomp{i}=cellfun(@(arg) linksOnly(arg,noOfNodes),alternativeslacomp{i},'UniformOutput', false);
end

cap = zeros(size(cap)) + max(GetCapacity(slacomp,cap,demand,noOfNodes));

Xcptime = cell2mat(X(1,:));
Xnfail = cell2mat(X(2,:));

CovXcptime = cov(Xcptime);
CovXnfail = cov(Xnfail);

MeanXcptime = mean(Xcptime);
MeanXnfail = mean(Xnfail);

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
P0.DNA = bsxfun(@eq,r0,max(r0));
[~, ~, R0] = FitnessFun(P0,Data,Weight,alphaV,0,Policy,RiskMeasure);


for i=1:4
    r = zeros(4,mm);
    r(i,:) = 1;
    Pop{i}.DNA = bsxfun(@eq,r,max(r));
    [Pop{i}.F, Pop{i}.C, Pop{i}.V] = funs{OptimF}(Pop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure);
    CC1(i) = Pop{i}.C;
    VV1(i) = Pop{i}.V;
end

plot(CC1,VV1,'black.','MarkerSize',20);
hold off