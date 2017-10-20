function [Surv] = GA_Select(Pop,PopulationSize,EliteCount,nParents)

    for i=1:PopulationSize
        tmpF(i) = Pop{i}.F;
    end
    
    [~, idx] = sort(tmpF,'descend');
%     [~, idx] = sort(tmpF);

    Pop = Pop(idx);


    for i=1:EliteCount
        Surv{i} = Pop{1};
        Pop(1) = [];
    end
    
    sumF = 0;
    for i=1:size(Pop,2)
        sumF = sumF + Pop{i}.F;
    end
    
    for i=(EliteCount+1):nParents
         rr1 = rand;
         tmp = 0;
         j=0;
         while tmp<rr1
             j = j + 1;
             tmp = tmp + Pop{j}.F/sumF;
         end
         Surv{i} = Pop{j};
         sumF = sumF - Pop{i}.F;
         Pop(i)=[];     
    end
    
    tmpF = [];
    for i=1:size(Surv,2)
        tmpF(i) = Surv{i}.F;
    end
    
    [~, idx] = sort(tmpF,'descend');
    Surv = Surv(idx);
    

%     for kk=1:PopulationSize-EliteSize
%         
%         sumF = 0;
%         for i=1:PopulationSize
%             sumF = sumF + NewPop{i}.F;
%         end
%         
%         rr1 = rand;
%         tmp = 0;
%         
%         Parent1 = zeros(PopulationSize-EliteSize);
%         while tmp<rr1
%             tmp = tmp + NewPop{i}.F/sumF;
%             Parent1(kk) = Parent1 + 1;
%         end
%          
%         rr2 = rand;
%         tmp = 0;      
%         Parent2 = zeros(PopulationSize-EliteSize);
%         while tmp<rr2
%             tmp = tmp + NewPop{i}.F/sumF;
%             Parent2(kk) = Parent2 + 1;
%         end       
%     end
    
    
end