clear
clc

RiskMeasures = [{'Var'},{'cVar'},{'mean'}];
Policies = [{'cptime'},{'nfail'}];
Nets = [{'GER'}, {'US'}];
%OptimF = [{@FitnessFun},{@FitnessFun2},{@FitnessFun3}];
CrashDatas = [{'symulacje/optim-germanyi-sbpp5.mat'},{'symulacje/optim-us-sbpp5.mat'}];
NetDatas = [{'sieci/slacomp-germany.mat'},{'sieci/slacomp-us.mat'}];

weights = [2000, 4000, 8000, 16000, 32000; 8, 16, 32, 64, 128];

%fid=fopen('params_new.txt','w');
for s = 1:2
    for r=1:3
        for p=1:2
            for c=1:2
                for w=1:5
                    RiskMeasure = RiskMeasures{r};
                    Policy = Policies{p};
                    Net = Nets{c};
                    OptimF = 4;
                    CrashData = CrashDatas{c};
                    NetData = NetDatas{c};
                    Weight = weights(p,w);

                    EdgeSeeking;
    %                    fprintf(fid,'%s %s %s %d symulacje/%s sieci/%s %d \n',RiskMeasures{r},Policies{p},Nets{c},f,CrashData{c},NetData{c},weights(p,w));
                end
            end
        end
    end
end
%fclose(fid)