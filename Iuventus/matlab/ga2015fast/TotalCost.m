function [C] = TotalCost(slacomp,slacomp2,alternativeslacomp,demand,ProtVector,cap,noOfNodes)
    uslacomp2=cellfun(@(arg) cellfun(@(arg2)arg2',arg,'UniformOutput',0),alternativeslacomp,'UniformOutput',0);
    function y = UnprotectedCost(idx)
%        len = length(slacomp{idx});
%        y = len*demand(idx);
         y = 0;
    end
    function y = DedicatedCost(idx)
        len = length(slacomp2{idx});
        y = len*demand(idx) + UnprotectedCost(idx);
    end
    function y = LinkDedicatedCost(idx)
        tmp = cell2mat(uslacomp2{idx});
        tmp = [tmp(:); slacomp{idx}'];
        n=length(unique(tmp));
        y=demand(idx)*n;
    end
    function y = SBPPCost(idx)
        y = UnprotectedCost(idx);
    end
    
    cost = {@UnprotectedCost, @DedicatedCost, @LinkDedicatedCost, @SBPPCost};

    C = 0;
    
    for i=1:size(ProtVector,2)
        col = ProtVector(:,i);
        fun = cost{col};
%         fun = fun{1};
        C = C + fun(i);
    end
    
    if sum(ProtVector(4,:)>0)
        SBPPcomp = slacomp2(ProtVector(4,:));
        C = C + sum(GetSBPPCapacity(SBPPcomp,cap,demand,noOfNodes));
    end
    
end