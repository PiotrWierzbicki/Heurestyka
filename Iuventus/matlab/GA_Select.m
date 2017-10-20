function [Surv] = GA_Select(Pop,PopulationSize,EliteCount)

    for i=1:PopulationSize
        tmpF(i) = Pop{i}.F;
    end
    
    [~, idx] = sort(tmpF);
      
    for i=1:EliteCount
        Surv{i} = Pop{idx(i)};
    end
    
end