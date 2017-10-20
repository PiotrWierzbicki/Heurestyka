% RiskMeasures = [{'Var'},{'cVar'},{'mean'}];
% Policies = [{'cptime'},{'nfail'}];
% Nets = [{'GER'}, {'US'}];
% OptimF = [{@FitnessFun},{@FitnessFun2},{@FitnessFun3}];
% CrashData = [{'optim-germanyi-sbpp5.mat'},{'optim-us-sbpp5.mat'}];
% NetData = [{'slacomp-germany.mat'},{'slacomp-us.mat'}];
% 
% weights = [10, 100, 1000, 10000];


RiskMeasure = paramFromEnv('RiskM','Var');
Policy = paramFromEnv('Policy','cptime');
Net = paramFromEnv('Nets','GER');
OptimF = paramFromEnv('OptimF',4);
Weight = paramFromEnv('Weight',10);

CrashData = paramFromEnv('CrashData','optim-germanyi-sbpp5.mat');
NetData = paramFromEnv('NetData','slacomp-germany.mat');


GA_OPTIM_NEW;