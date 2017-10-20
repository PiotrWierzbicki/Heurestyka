load BestConf.mat

for i=1:240
    
    file=[num2str(i),'.txt'];
%    data=importdata(file);
    lbl=importdata([file,'.lbl']);
    
    if(strcmp(BestConf{i}.Net,'GER'))
        load('demand-ger');
    else
        load('demand-us');
    end
    
    if(strcmp(BestConf{i}.Policy,'cptime'))
        Protection = {'UnprotectedAvail', 'DedicatedAvail', 'LinkDedicatedAvail', 'SBPPAvail'};
    else
        Protection = {'UnprotectedCont', 'DedicatedCont', 'LinkDedicatedCont', 'SBPPCont'};
    end

    XT = 0;
    
    for j=1:3
        idx = cellfun(@(arg) strcmp(arg,Protection{j}),lbl)';
        X = data(:,idx);
        X = X(:,BestConf{i}.DNA(j,:));
        dem = demand(BestConf{i}.DNA(j,:));
        X = X*diag(dem);
        XT = XT + sum(X,2);
    end
    
    idx = cellfun(@(arg) strcmp(arg,'SBPPAvail'),lbl)';
    X = data(:,idx);
    dem = demand(BestConf{i}.DNA(4,:));
    X = X*diag(dem);
    
    XT = XT + sum(X,2);
    
    alpha = 0.95;

    if(strcmp(BestConf{i}.RiskMeasure,'Var'))
        Risk(i) = quantile(XT,alpha);
    elseif(strcmpy(BestConf{i}.RiskMeasure,'cVar'))
        Risk(i) = cVarNum(XT,alpha);
    else
        Risk(i) = mean(XT);
    end
    
    RiskEst(i) = BestConf{i}.Risk;

end

save Comparison.mat Risk RiskEst

