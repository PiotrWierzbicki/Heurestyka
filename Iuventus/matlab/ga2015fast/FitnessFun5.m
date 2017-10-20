function [F] = FitnessFun5(Pop,CC,VV,n)

%     C = TotalCost(Data.slacomp,Data.slacomp2,Data.alternativeslacomp,Data.demand,I.DNA,Data.cap,Data.noOfNodes);
%     
%     if strcmp(RiskMeasure,'mean')
%         NDNA = I.DNA';
%         NDNA = NDNA(:);
%         if strcmp(policy,'cptime')
%             MeanX = Data.MeanXcptime;
%             CovX = Data.CovXcptime;
%             Risk = MeanX*NDNA;
%         elseif strcmp(policy,'nfail')
%             MeanX = Data.MeanXnfail;
%             CovX = Data.CovXnfail;
%             Risk = MeanX*NDNA;
%         else
%             display 'Incorrect policy\n';
%             return
%         end
%     else
%         XT = zeros(100000,1);
%         nn = size(I.DNA,2);
% 
%         if strcmp(policy,'cptime')
%             for i=1:nn
%                 tmp = I.DNA(:,i);
%                 XT = XT + Data.X{1,tmp}(:,i);
%             end
%         elseif strcmp(policy,'nfail')
%             for i=1:nn
%                 tmp = I.DNA(:,i);
%                 XT = XT + Data.X{2,tmp}(:,i);
%             end
%         else
%             display 'Incorrect policy\n';
%             return
%         end
% 
%         if strcmp(RiskMeasure,'Var')
%             Risk = quantile(XT,alpha);
%         elseif strcmp(RiskMeasure,'cVar')
%             Risk = cVarNum(XT,alpha);
%         else
%             display 'Incorrect RiskMeasure';
%             return
%         end
%     end
    
    deltaC = [];
    deltaV = [];
    dF = [];
    
    deltaC = CC - CC(n);
    deltaC(n) = [];
    
    deltaV = VV - VV(n);
    deltaV(n) = [];
    
    dF = max(deltaC, deltaV);
    %%%%% Do zoptymalizowania!!! %%%%%%
%     for i=1:size(Pop,2)
%         if(i~=n)
%             deltaC = (Pop{i}.C - Pop{n}.C);
%             deltaV = (Pop{i}.V - Pop{n}.V);
%             dF = [dF max(deltaC, deltaV)];
%         end 
%     end

    F = min(dF);
%    F = min(dF) + abs(Pop{n}.C - Pop{n}.V)/10;
    if(F<0)
        F = 0;
    end
end