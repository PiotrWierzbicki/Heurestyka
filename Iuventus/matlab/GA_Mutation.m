function NewPop = GA_Mutation(Pop, EliteCount,beta)
    NewPop = Pop;
    for i=EliteCount:size(Pop,2)
        r = rand(size(Pop{1}.DNA,2));
        for j=1:size(r)
            if(r(j)<beta)
                r2 = randi(4);
                NewPop{i}.DNA(:,j)=0;
                NewPop{i}.DNA(r2,j)=1;
            end
        end
    end
end