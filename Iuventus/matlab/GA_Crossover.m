function [NewPop] = GA_Crossover(Parents,PopulationSize,EliteSize,Data)

    nChildren = PopulationSize - EliteSize;
    nParents = size(Parents,2);
    nPairs = floor(nParents/2);
    DNA_size = size(Data.slacomp,2);
    
    n = nParents;
    r = randperm(2*nPairs);  
    
    NewPop(1:nParents) = Parents;
    while size(NewPop,2) < PopulationSize
        for i=1:nPairs
            rg = randperm(DNA_size);
            DNA_A(:,rg(1:floor(DNA_size/2))) = Parents{r(i)}.DNA(:,rg(1:floor(DNA_size/2)));
            DNA_A(:,rg(floor(DNA_size/2)+1:end)) = Parents{r(i+nPairs)}.DNA(:,rg(floor(DNA_size/2)+1:end));
            DNA_B(:,rg(1:floor(DNA_size/2))) = Parents{r(i+nPairs)}.DNA(:,rg(1:floor(DNA_size/2)));
            DNA_B(:,rg(floor(DNA_size/2)+1:end)) = Parents{r(i)}.DNA(:,rg(floor(DNA_size/2)+1:end));

            n = n + 1;
            NewPop{n}.DNA = DNA_A;
%            NewPop{n}.F = FitnessFun(NewPop{n},Data);

            n = n + 1;
            NewPop{n}.DNA = DNA_B;
%            NewPop{n}.F = FitnessFun(NewPop{n},Data);
        end
    end
    
    if size(NewPop,2) > PopulationSize
        NewPop(PopulationSize+1:end) = [];
    end
    
end