clear
clc

for yy = 2:2
    pol = yy-1;
    if(pol==0)
        pp = 'cptime';
    else
        pp = 'nfail';
    end

    for zz = 1:2
        if(zz==1)    
            s1 = 'optim-germanyi-sbpp5.mat';
            s2 = 'slacomp-germany.mat';
            siec = 'GER';
        else
            s1 = 'optim-us-sbpp5.mat';
            s2 = 'slacomp-us.mat';
            siec = 'US'
        end

        helper_optim2

        Data.slacomp = slacomp;
        Data.slacomp2 = slacomp2;
        Data.alternativeslacomp = alternativeslacomp;
        Data.X = X;
        Data.demand = demand;
        Data.cap = cap;
        Data.noOfNodes = noOfNodes;
        mm = size(slacomp,2);
        alpha = 0.95;

        weights = [10, 100, 1000, 10000];

        nRand = 10000;

        CC = zeros(1,nRand);
        RR = zeros(1,nRand);

        for kk = 1:4
            for i=1:nRand
                C_weight = weights(kk);
                if(mod(i,100)==0)
                    display(kk)
                    display(i)
                end
                r=rand(4,mm);
        %         r0 = zeros(1,mm)-1;
        %         r=rand(2,mm);
        %         r = [r0;r;r0];
            %       r = zeros(4,121);
            %       r(3,:) = 1;
                XX.DNA = bsxfun(@eq,r,max(r));
                CC(i) = C_weight*TotalCost(Data.slacomp,Data.slacomp2,Data.alternativeslacomp,Data.demand,XX.DNA,Data.cap,Data.noOfNodes);

                XT = zeros(100000,1);
                for j=1:mm
                    tmp = XX.DNA(:,j);
                    XT = XT + Data.X{yy,tmp}(:,j);
                end

                RR(i) = quantile(XT,alpha);
            end

            s = ['Rand', num2str(nRand), siec, '_', pp, '_C', num2str(C_weight),'.mat'];
            save(s, 'CC', 'RR', 'alpha', 'C_weight', 'nRand', 'slacompName', 'plik', 'policy')
        end

    end
    
end
