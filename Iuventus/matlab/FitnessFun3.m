function [R, C, Risk] = FitnessFun3(I,Data,C_weight,alpha,R0,policy,RiskMeasure)
    C = TotalCost(Data.slacomp,Data.slacomp2,Data.alternativeslacomp,Data.demand,I.DNA,Data.cap,Data.noOfNodes);

    XT = zeros(100000,1);
    
    nn = size(I.DNA,2);
    
    if strcmp(policy,'cptime')
        for i=1:nn
            tmp = I.DNA(:,i);
            XT = XT + Data.X{1,tmp}(:,i);
        end
    elseif strcmp(policy,'nfail')
        for i=1:nn
            tmp = I.DNA(:,i);
            XT = XT + Data.X{2,tmp}(:,i);
        end
    else
        display 'Incorrect policy\n';
        return
    end
    
    if strcmp(RiskMeasure,'Var')
        Risk = quantile(XT,alpha);
    elseif strcmp(RiskMeasure,'cVar')
        Risk = cVarNum(XT,alpha);
    elseif strcmp(RiskMeasure,'mean')
        Risk = mean(XT);
    else
        display 'Incorrect risk measure\n';
        return
    end

    C = C_weight*C;
    R = abs(C - Risk);
end