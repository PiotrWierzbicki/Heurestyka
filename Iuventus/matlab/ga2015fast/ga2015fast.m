RiskMeasure = paramFromEnv('RiskM','Var');
Policy = paramFromEnv('Policy','linear');
Net = paramFromEnv('Nets','GER');
OptimF = paramFromEnv('OptimF',1);
Weight = paramFromEnv('Weight',512000);
%%
CrashData = paramFromEnv('CrashData','symulacje/optim-germanyi-sbpp5.mat');
NetData = paramFromEnv('NetData','sieci/slacomp-germany.mat');


%out='slacomp-germany.js'
out=[tempname,'.js'];
[noOfNodes, cap, slacomp, slacomp2, alternativeslacomp] = Slacomp2JasonNoRouterF('../sieci/slacomp-germany.mat',3.18e-7,2.3, 60,0.8,out)

% czytamy konfig
js=fileread(out);
data=parse_json(js);
thr=min(cellfun(@(x) 1/x.dlambda, data{1,1}.components));

%% Przygotowujemy stany
N=10000; % liczba iteracji
[states,times]= createstates(js,N,1,3,1,1); 

N2=N;
if strcmp(Policy,'linear')
    
    [r,lbl]= netfailsimex(js,N2,1,3,4,1);% Exp,Par,Avail

    unprotected=r(strcmp(lbl,'UnprotectedLinearCost'),:);

    dedicated=r(strcmp(lbl,'DedicatedLinearCost'),:);
    ldedicated=r(strcmp(lbl,'LinkDedicatedLinearCost'),:);
else
    [r,lbl]= netfailsimex(js,N2,1,3,6,1);% Exp,Par,Avail

    unprotected=r(strcmp(lbl,'UnprotectedSnowball'),:);

    dedicated=r(strcmp(lbl,'DedicatedSnowball'),:);
    ldedicated=r(strcmp(lbl,'LinkDedicatedSnowball'),:);

end
clear r

%% parametry do sbpp
limits=cellfun(@(x) x.sbppLimit ,data{1}.components); %limity na pasmo sbpp
primaries=uint64(cellfun(@(x) path2bits(x.path),data{1}.slas));
secondaries=uint64(cellfun(@(x) path2bits(x.backupPath),data{1}.slas));

demand=cellfun(@(x) x.demand,data{1}.slas);
%ustawiamy  na 0 tam gdzie nie ma sbpp

slacomp=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp,'UniformOutput', false);
slacomp2=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp2,'UniformOutput', false);

for i=1:length(alternativeslacomp)
    alternativeslacomp{i}=cellfun(@(arg) linksOnly(arg,noOfNodes),alternativeslacomp{i},'UniformOutput', false);
end

cap = zeros(size(cap)) + max(GetCapacity(slacomp,cap,demand,noOfNodes));%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


PopulationSize = 40;
EliteCount = 4;
nParents = 20;

alphaV = 0.95;
betaV = 0.01;

maxIter = 2500;
minIter = 1;
maxConstantIter = 100;

funs = [{@FitnessFun},{@FitnessFun2},{@FitnessFun3}];

s1 = CrashData;
s2 = NetData;

Data.slacomp = slacomp;
Data.slacomp2 = slacomp2;
Data.alternativeslacomp = alternativeslacomp;

Data.unpr = unprotected;
Data.ded = dedicated;
Data.lded = ldedicated;

%Data.CovX = CovX;
%Data.MeanX = MeanX;
Data.demand = demand;
Data.cap = cap;
Data.noOfNodes = noOfNodes;

%%


mm = size(slacomp,2);

P0={};

r0=zeros(4,mm);
r0(1,:) = 1;
P0{1}.DNA = bsxfun(@eq,r0,max(r0));

Rrand = randi(10000,1,1000);
sbppcost=sbpp_w(states(Rrand),times(Rrand),primaries,secondaries,demand.*P0{1}.DNA(4,:),limits, Policy, thr);
%Data.X = [Data.X; sbppcost'];



[~, ~, R0] = FitnessFun(P0{1},Data,Weight,alphaV,0,Policy,RiskMeasure,sbppcost,1000);

tic
for ii=1:4
    r0=zeros(4,mm);
    r0(ii,:) = 1;
    P0{ii}.DNA = bsxfun(@eq,r0,max(r0));
    Rrand = randi(10000,1,1000);
    sbppcost=sbpp_w(states(Rrand),times(Rrand),primaries,secondaries,demand.*P0{ii}.DNA(4,:),limits, Policy, thr);
    [P0{ii}.F, P0{ii}.C, P0{ii}.V] = funs{OptimF}(P0{ii},Data,Weight,alphaV,R0,Policy,RiskMeasure,sbppcost,1000);
%    plot(P0{ii}.C,P0{ii}.V,'black.', 'MarkerSize', 20);
%    hold on
end

%waitforbuttonpress
toc

%%

% [~, ~, R0] = FitnessFun(P0{1},Data,Weight,alphaV,R0,Policy,RiskMeasure);


CC = [];
VV = [];
CC0 = zeros(1,PopulationSize);
VV0 = zeros(1,PopulationSize);

% for i=1:PopulationSize
%     r=rand(4,mm);
%     Pop{i}.DNA = bsxfun(@eq,r,max(r));
%     Rrand = randi(10000,1,1000);
%     sbppcost=sbpp(states(Rrand),times(Rrand),primaries,secondaries,demand.*Pop{i}.DNA(4,:),limits);
%     [Pop{i}.F, Pop{i}.C, Pop{i}.V] = funs{OptimF}(Pop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure, sbppcost,1000);
%     CC0(i) = Pop{i}.C;
%     VV0(i) = Pop{i}.V;
% end

for i=1:PopulationSize
    for k=1:4
%        r=rand(4,mm);
        r = zeros(4,121);
        r((mod(i,k)+1),:) = 1;
        Pop{i}.DNA = bsxfun(@eq,r,max(r));
        Rrand = randi(10000,1,1000);
        sbppcost=sbpp_w(states(Rrand),times(Rrand),primaries,secondaries,demand.*Pop{i}.DNA(4,:),limits, Policy, thr);
        [Pop{i}.F, Pop{i}.C, Pop{i}.V] = funs{OptimF}(Pop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure, sbppcost,1000);
        CC0(i) = Pop{i}.C;
        VV0(i) = Pop{i}.V;
    end
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

    for i=1:PopulationSize
        tmpF(i) = Pop{i}.F;
        tmpC(i) = Pop{i}.C;
        tmpV(i) = Pop{i}.V;
    end

tic
while (num<=maxConstantIter && j<=maxIter)

    Surv = GA_Select(Pop,PopulationSize,EliteCount,nParents);  
    NewPop = GA_Crossover(Surv,PopulationSize,EliteCount,Data);
    NewPop = GA_Mutation(NewPop,nParents,betaV);

    if(j<1000)
        for i=1:PopulationSize
            Rrand = randi(10000,1,10);
            sbppcost=sbpp_w(states(Rrand),times(Rrand),primaries,secondaries,demand.*NewPop{i}.DNA(4,:),limits, Policy, thr);
            [NewPop{i}.F, NewPop{i}.C, NewPop{i}.V] = funs{OptimF}(NewPop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure,sbppcost,10);
        end
    elseif(j==1000)
        for i=1:PopulationSize
            Rrand = randi(10000,1,100);
            sbppcost=sbpp_w(states(Rrand),times(Rrand),primaries,secondaries,demand.*NewPop{i}.DNA(4,:),limits, Policy, thr);
            [NewPop{i}.F, NewPop{i}.C, NewPop{i}.V] = funs{OptimF}(NewPop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure,sbppcost,100);
        end
    elseif(j<1800)
        for i=1:PopulationSize
            Rrand = randi(10000,1,100);
            sbppcost=sbpp_w(states(Rrand),times(Rrand),primaries,secondaries,demand.*NewPop{i}.DNA(4,:),limits, Policy, thr);
            [NewPop{i}.F, NewPop{i}.C, NewPop{i}.V] = funs{OptimF}(NewPop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure,sbppcost,100);
        end
    elseif(j==1800)
        for i=1:PopulationSize
            Rrand = randi(10000,1,1000);
            sbppcost=sbpp_w(states(Rrand),times(Rrand),primaries,secondaries,demand.*NewPop{i}.DNA(4,:),limits, Policy, thr);
            [NewPop{i}.F, NewPop{i}.C, NewPop{i}.V] = funs{OptimF}(NewPop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure,sbppcost,1000);
        end
    else
        for i=1:PopulationSize
            Rrand = randi(10000,1,1000);
            sbppcost=sbpp_w(states(Rrand),times(Rrand),primaries,secondaries,demand.*NewPop{i}.DNA(4,:),limits, Policy, thr);
            [NewPop{i}.F, NewPop{i}.C, NewPop{i}.V] = funs{OptimF}(NewPop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure,sbppcost,1000);
        end
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
    
%     hold off
%     plot(CC(max(1,size(CC,2)-1000):end),VV(max(1,size(VV,2)-1000):end),'g+');
%     hold on
%     pause(0.01)
    
%    plot(tmpC,tmpV,'black.');
%    hold on
%    pause(0.01)

    meann(j) = mean(tmpF);
    minn(j) = min(tmpF);
    maxx(j) = max(tmpF);

    Pop = NewPop;

    if(j > minIter && maxx(j)==maxx(j-1))
        num = num + 1;
    elseif(j > minIter && maxx(j)>maxx(j-1))
        num = 0;
%     elseif(j > minIter && maxx(j)<maxx(j-1))
%         disp('POPULATION ERROR')
%         waitforbuttonpress
    end

    j = j + 1;
    disp(j);
    toc
end

s = ['wyniki/',RiskMeasure, '_', Policy, '_', Net, '_', num2str(OptimF), '_', num2str(Weight), '.mat'];
save(s, 'NewPop', 'P0', 'maxx', 'betaV', 'EliteCount', 'nParents', 'PopulationSize', 'CC', 'VV', 'CC0', 'VV0','RiskMeasure', 'Policy','Net', 'OptimF','Weight');
 
exit


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










