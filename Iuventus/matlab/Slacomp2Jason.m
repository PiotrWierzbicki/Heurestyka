% przygotowanie jsona z konfiguracja sieci
clear

lambdar=paramFromEnv('LAMBDAR',3.18e-7);
alpha=paramFromEnv('ALPHA',2.3);
betam=paramFromEnv('BETAM',60);
% betam=paramFromEnv('BETAM',1);
plik=paramFromEnv('PLIK','plik2.mat');
%0.6000    1.2000    1.8000    2.4000    3.0000
%alpha=0.6000;
% alpha=1.2000;
% alpha=1.8000;
% alpha=2.4000;
% alpha=3.0000;

tmax=12*30*24*3600;%rok

slacompName=paramFromEnv('SLACOMP','sieci/slacomp-germany.mat');
slacompName=paramFromEnv('SLACOMP','sieci/slacomp-us.mat');
load(slacompName);
policy=paramFromEnv('POLICY','cptime');
th=paramFromEnv('POL_TH',0);
global isPareto;
isPareto=boolean(paramFromEnv('PARETO',1));
qq=boolean(paramFromEnv('EXIT_MATLAB',0));
protection=boolean(paramFromEnv('PROTECTION',1));
w=boolean(paramFromEnv('W',0.3));
%% limity sbpp
sbpplimit=zeros(length(slacomp), length(cap));
for i=1:length(slacomp)
    p=slacomp2{i}-noOfNodes;
    p=p(p>0);
    sbpplimit(i,p)=demand(i);
end
sbpplimit=max(sbpplimit);
%% sbpl limit
sbpllimit=[];


for i=1:length(alternativeslacomp)
    tmp1=alternativeslacomp{i}
    for j=1:length(tmp1)
        p = tmp1{j}-noOfNodes;
        p=p(p>0);
        limit_tmp=zeros(1,length(cap));
        limit_tmp(p)=demand(i);
        sbpllimit=[sbpllimit;limit_tmp];
    end
end
sbpllimit = max(sbpllimit);
%%
fid =fopen([slacompName,'_',num2str(alpha),'_','.json'],'w');
%fid =fopen([slacompName,'.json.tmpl'],'w');
fid =fopen([slacompName,'.js'],'w');
fprintf(fid,'{\n	"components":[\n		')

for i =noOfNodes+1:length(params)
    param=params{i};
    if param.l < 25
        lambda=lambdar;
        beta=betam;
    else
        lambda = lambdar + 9*lambdar*param.l/param.lmax;
        beta = betam + 9*betam*param.l/param.lmax;
    end

    %http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=5763399
    wa=0.35;
    wb=1/lambda/gamma(1+1/wa);
%     lambda
%     alpha
%     beta
    fprintf(fid,'{"lambda":%e, "alpha":%e, "beta":%e,  "sbppLimit":%e,  "sbplLimit":%e,  "wa":%e,  "wb":%e}',lambda,alpha,beta,sbpplimit(i-noOfNodes), sbpllimit(i-noOfNodes),wa,wb)
    if i < length(params)
        fprintf(fid,',\n		');
    else
        fprintf(fid,'\n');
    end
end

fprintf(fid,'	],\n	"slas":[\n');

for i=1:length(demand)
    
    tmp={};
    tmp2=alternativeslacomp{i};
    
    for j=1:length(tmp2)
        tmp{end+1}=sprintf('[%s]',mat2strwcoma(noRouters(tmp2{j},noOfNodes)));
        if j < length(tmp2)
           tmp{end+1}=',';
        end
    end
    sbppPlace=['#SBPP',num2str(i)];
    sbppPlace='%d';
    fprintf(fid,'	{\n		"path":[%s],\n		"backupPath":[%s],\n		"linkBackup":[%s],\n		"demand":%f,\n		"useSBPP":%d,\n		"useSBLP":%d\n	}',...
        mat2strwcoma(noRouters(slacomp{i},noOfNodes)),...
        mat2strwcoma(noRouters(slacomp2{i},noOfNodes)),...
        cell2mat(tmp), demand(i),1,0);
     if i < length(demand)
        fprintf(fid,',\n');
    else
        fprintf(fid,'\n');
    end

end
fprintf(fid,'	]\n}');
fclose(fid)

