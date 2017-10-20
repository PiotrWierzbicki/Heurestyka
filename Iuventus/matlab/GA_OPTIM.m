clear
clc

RiskMeasures = [{'Var'},{'cVar'},{'mean'}];
Policies = [{'cptime'},{'nfail'}];
Nets = [{'GER'}, {'US'}];
OptimF = [{@FitnessFun},{@FitnessFun2},{@FitnessFun3}];
CrashData = [{'optim-germanyi-sbpp5.mat'},{'optim-us-sbpp5.mat'}];
NetData = [{'slacomp-germany.mat'},{'slacomp-us.mat'}];

weights = [10, 100, 1000, 10000];


%%%%%%%%%%%%%%%%%%%
PopulationSize = 40;
EliteCount = 10;

alphaV = 0.95;
betaV = 0.025;

maxIter = 2000;
minIter = 1;
maxConstantIter = 500;

%%

for yy = 1:2
    pol = yy-1;
    pp = Policies{yy};
    
    for zz = 1:2
        siec = Nets{zz};
        s1 = CrashData{zz};
        s2 = NetData{zz};

        helper_optim

        Data.slacomp = slacomp;
        Data.slacomp2 = slacomp2;
        Data.alternativeslacomp = alternativeslacomp;
        Data.X = X;
        Data.demand = demand;
        Data.cap = cap;
        Data.noOfNodes = noOfNodes;

        mm = size(slacomp,2);
        
        for kk=1:4
            C_weight = weights(kk);
            
        %%%%%%%%%%%%%    
        r0=zeros(4,121);
        r0(1,:) = 1;
        P0.DNA = bsxfun(@eq,r0,max(r0));
        [~, ~, R0] = FitnessFun(P0,Data,C_weight,alphaV,pp,'Var');
        %%%%%%%%%%%%%%%%%%%    
            
            CC = [];
            VV = [];
            CC0 = zeros(1,PopulationSize);
            VV0 = zeros(1,PopulationSize);
            for i=1:PopulationSize
                r=rand(4,mm);
                Pop{i}.DNA = bsxfun(@eq,r,max(r));
                [Pop{i}.F, Pop{i}.C, Pop{i}.V] = FitnessFun2(Pop{i},Data,C_weight,alphaV,R0,pp,'Var');
                CC0(i) = Pop{i}.C;
                VV0(i) = Pop{i}.V;
            end

            for i=1:4
                r = zeros(4,mm);
                r(i,:) = 1;
                Pop{i}.DNA = bsxfun(@eq,r,max(r));
                [Pop{i}.F, Pop{i}.C, Pop{i}.V] = FitnessFun2(Pop{i},Data,C_weight,alphaV,R0,pp,'Var');
                CC0(i) = Pop{i}.C;
                VV0(i) = Pop{i}.V;
            end
            
            j = 1;
            num = 0;
            while (num<=maxConstantIter && j<=maxIter)

                Surv = GA_Select(Pop,PopulationSize,EliteCount);  
                NewPop = GA_Crossover(Surv,PopulationSize,EliteCount,Data);
                NewPop = GA_Mutation(NewPop,EliteCount,betaV);

                for i=1:PopulationSize
                    [NewPop{i}.F, NewPop{i}.C, NewPop{i}.V] = FitnessFun2(NewPop{i},Data,C_weight,alphaV,R0,pp,'Var');
                end

        %         for i=1:PopulationSize
        %             tmpF(i) = Pop{i}.F;
        %         end

                for i=1:PopulationSize
                    tmpF(i) = NewPop{i}.F;
                    tmpC(i) = NewPop{i}.C;
                    tmpV(i) = NewPop{i}.V;
                end

                CC = [CC tmpC];
                VV = [VV tmpV];

                meann(j) = mean(tmpF);
                minn(j) = min(tmpF);

                min_a = (min(tmpF));
                mean_a = (mean(tmpF));

                clc
                display (j)
                display (min_a)
                display (mean_a)

                Pop = NewPop;

                if(j > minIter && minn(j)==minn(j-1))
                    num = num + 1;
                elseif(j > minIter && minn(j)<minn(j-1))
                    num = 0;
                end

                clc
                display(kk)
                display(j)
                display(num)     

                j = j + 1;     
            end

             s = [siec , '_' , pp, 'minRplusB_', 'C' num2str(C_weight),'.mat'];
%             save(s, 'NewPop', 'minn', 'plik', 'policy', 'slacompName', 'beta', 'C_weight', 'EliteCount', 'PopulationSize', 'CC', 'VV', 'CC0', 'VV0');
%             clear minn meann NewPop Pop Surv
        end

    end

end
