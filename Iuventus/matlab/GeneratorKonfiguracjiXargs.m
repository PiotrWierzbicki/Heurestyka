RiskMeasures = [{'Var'},{'cVar'},{'mean'}];
Policies = [{'cptime'},{'nfail'}];
Nets = [{'GER'}, {'US'}];
%OptimF = [{@FitnessFun},{@FitnessFun2},{@FitnessFun3}];
CrashData = [{'optim-germanyi-sbpp5.mat'},{'optim-us-sbpp5.mat'}];
NetData = [{'slacomp-germany.mat'},{'slacomp-us.mat'}];

weights = [10, 100, 1000, 10000];
fid=fopen('params.txt','w');
for r=1:3
    for p=1:2
        for c=1:2
            for f=1:3
                for w=1:4
                    fprintf(fid,'%s %s %s %d symulacje/%s sieci/%s %d \n',RiskMeasures{r},Policies{p},Nets{c},f,CrashData{c},NetData{c},weights(w));
                end
            end
        end
    end
end
fclose(fid)