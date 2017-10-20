function [NewPop] = GA_Crossover(Parents,PopulationSize,EliteSize,Data)

    nChildren = PopulationSize - EliteSize;
    nParents = size(Parents,2);
    nPairs = floor(nParents/2);
    DNA_size = size(Data.slacomp,2);
    
    n = EliteSize;
%    r = randperm(2*nPairs);  
    
    NewPop(1:EliteSize) = Parents(1:EliteSize);
    tic
    for kk=1:PopulationSize-EliteSize
        
        sumF = 0;
        for i=1:nParents
            sumF = sumF + Parents{i}.F;
        end
        if sumF==0
            sumF = 0.1;
        end
        
        rr1 = rand;
        tmp = 0;        
        Parent1 = 0;
        while tmp<rr1 && Parent1<nParents
            Parent1 = Parent1 + 1;
            tmp = tmp + Parents{Parent1}.F/sumF;
        end
        if tmp==0
            Parent1 = randi(nParents,1);
        end
            
        p2 = Parent1;
       
        while p2 == Parent1
            rr2 = rand;
            tmp = 0;  
            Parent2 = 0;
            
            while tmp<rr2 && Parent2<nParents
                Parent2 = Parent2 + 1;
                tmp = tmp + Parents{Parent2}.F/sumF;
            end
            if tmp==0
                Parent2 = randi(nParents,1);
            end
            if(Parent2 == Parent1 && Parent2==1)
                Parent2 = Parent2 + 1;
            end
            p2 = Parent2;
        end
        
        if tmp==0
            Parent2 = randi(nParents,1);
        end
        
        rg = randperm(DNA_size);
        DNA_A(:,rg(1:floor(DNA_size/2))) = Parents{Parent1}.DNA(:,rg(1:floor(DNA_size/2)));
        DNA_A(:,rg(floor(DNA_size/2)+1:end)) = Parents{Parent2}.DNA(:,rg(floor(DNA_size/2)+1:end));
        DNA_B(:,rg(1:floor(DNA_size/2))) = Parents{Parent2}.DNA(:,rg(1:floor(DNA_size/2)));
        DNA_B(:,rg(floor(DNA_size/2)+1:end)) = Parents{Parent1}.DNA(:,rg(floor(DNA_size/2)+1:end));

        n = n + 1;
        NewPop{n}.DNA = DNA_A;
%            NewPop{n}.F = FitnessFun(NewPop{n},Data);

        NewPop{n}.DNA = DNA_B;
%            NewPop{n}.F = FitnessFun(NewPop{n},Data);
          
    end
    
    
%     while size(NewPop,2) < PopulationSize
%         for i=1:nPairs
%             rg = randperm(DNA_size);
%             DNA_A(:,rg(1:floor(DNA_size/2))) = Parents{r(i)}.DNA(:,rg(1:floor(DNA_size/2)));
%             DNA_A(:,rg(floor(DNA_size/2)+1:end)) = Parents{r(i+nPairs)}.DNA(:,rg(floor(DNA_size/2)+1:end));
%             DNA_B(:,rg(1:floor(DNA_size/2))) = Parents{r(i+nPairs)}.DNA(:,rg(1:floor(DNA_size/2)));
%             DNA_B(:,rg(floor(DNA_size/2)+1:end)) = Parents{r(i)}.DNA(:,rg(floor(DNA_size/2)+1:end));
% 
%             n = n + 1;
%             NewPop{n}.DNA = DNA_A;
% %            NewPop{n}.F = FitnessFun(NewPop{n},Data);
% 
%             n = n + 1;
%             NewPop{n}.DNA = DNA_B;
% %            NewPop{n}.F = FitnessFun(NewPop{n},Data);
%         end
%     end
%     
%     if size(NewPop,2) > PopulationSize
%         NewPop(PopulationSize+1:end) = [];
%     end
    
end