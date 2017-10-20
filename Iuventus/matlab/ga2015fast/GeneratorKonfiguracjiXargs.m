RiskMeasures = [{'Var'}];
Policies = [{'linear'},{'snowball'}];
Nets = [{'GER'}];
OptimF = [{@FitnessFun},{@FitnessFun2},{@FitnessFun3}];
CrashData = [{'optim-germanyi-sbpp5.mat'}];
NetData = [{'slacomp-germany.mat'}];

weights = [1000, 2000, 4000, 8000, 16000, 20000, 24000, 28000, 32000, 36000, 40000, 44000, 48000, 52000, 56000, 60000, 64000, 128000, 256000, 512000];

fid=fopen('params.txt','w');
for g=1:2
    for f=1:3
        for w=1:20
            fprintf(fid,'%s %s %s %d symulacje/%s sieci/%s %d \n',RiskMeasures{1},Policies{g},Nets{1},f,CrashData{1},NetData{1},weights(w));
        end
    end
end
fclose(fid)