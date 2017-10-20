function [R, C, Risk] = FitnessFun3(I,Data,C_weight,alpha,R0,policy,RiskMeasure)

    C = TotalCost(Data.slacomp,Data.slacomp2,Data.alternativeslacomp,Data.demand,I.DNA,Data.cap,Data.noOfNodes);
    
    if strcmp(RiskMeasure,'mean')
        NDNA = I.DNA';
        NDNA = NDNA(:);
        if strcmp(policy,'cptime')
            MeanX = Data.MeanXcptime;
            CovX = Data.CovXcptime;
            Risk = MeanX*NDNA;
        elseif strcmp(policy,'nfail')
            MeanX = Data.MeanXnfail;
            CovX = Data.CovXnfail;
            Risk = MeanX*NDNA;
        else
            display 'Incorrect policy\n';
            return
        end
    else
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
        else
            display 'Incorrect RiskMeasure';
            return
        end
    end
    
    C = C_weight*C;
    R = Risk;
    
    if(C>Risk)
        R = R + (C-Risk);
    end
    R = R0/R;
end