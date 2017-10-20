RiskMeasures = [{'Var'},{'cVar'},{'mean'}];
Policies = [{'cptime'},{'nfail'}];
Nets = [{'GER'}, {'US'}];
%OptimF = [{@FitnessFun},{@FitnessFun2},{@FitnessFun3}];
CrashData = [{'optim-germanyi-sbpp5.mat'},{'optim-us-sbpp5.mat'}];
NetData = [{'slacomp-germany.mat'},{'slacomp-us.mat'}];

weights = [2000, 4000, 8000, 16000, 32000; 8, 16, 32, 64, 128];

fid=fopen('params2correct.txt','w');
for r=1:3
    for p=1:2
        for c=1:2
            for f=2:2
                for w=1:5
%                    for StartConf=1:5
                        fprintf(fid,'%s %s %s %d symulacje/%s sieci/%s %d \n',RiskMeasures{r},Policies{p},Nets{c},f,CrashData{c},NetData{c},weights(p,w));
                    end
                end
%            end
        end
    end
end
fclose(fid)