% przygotowanie jsona z konfiguracja sieci
function [noOfNodes, cap, slacomp, slacomp2, alternativeslacomp] = Slacomp2JsonNoRouterF(slacompName,lambdar,alpha,betam,wa,dstFile)

load(slacompName);

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
%fid =fopen([slacompName,'_',num2str(alpha),'_','.json'],'w');
%fid =fopen([slacompName,'.json.tmpl'],'w');
fid =fopen(dstFile,'w');
fprintf(fid,'{\n	"components":[\n		')

for i =noOfNodes+1:length(params)
    param=params{i};
    if strcmp(param.type, 'l')
        if param.l < 25
            lambda=lambdar;
            beta=betam;
        else
            lambda = lambdar + 9*lambdar*param.l/param.lmax;
            beta = betam + 9*betam*param.l/param.lmax;
        end
    else
        lambda=lambdar;
        beta=betam;
    end
    


%srednia pareto beta*alpha/(alpha-1)
%variancja beta^2*alpha/((alpha-1)^2*(alpha-2));
%weib mean =wb*gamm(1+1/wa)
%weivar=wb^2(gamma(1+2/wa)-(gamma(1+1/wa)^2))
    %http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=5763399
    %wa=0.35;
    wb=1/lambda/gamma(1+1/wa);
    %dopasowanie std
    %wb=1/(lambda*sqrt(gamma(1+2/wa)-gamma(1+1/wa)^2));
    dpa=alpha;
    dpb=beta;
    dlambda=expfrompareto(dpa,dpb); %srednia exp taka jak dla pareto
    [dwa,dwb]=wblfrompareto(dpa, dpb);
    [dlm,dls]=lognfrompareto(dpa,dpb);
%     lambda
%     alpha
%     beta

sbppLimit=0;
sbplLimit=0;

if i > noOfNodes
    sbppLimit=sbpplimit(i-noOfNodes);
    sbplLimit=sbpllimit(i-noOfNodes);
else %router nie ma limitu
    sbppLimit=1e5;
    sbplLimit=1e5;
end
    fprintf(fid,'{"ulambda":%e, "dpa":%e, "dpb":%e,  "sbppLimit":%e,  "sbplLimit":%e,  "uwa":%e,  "uwb":%e, "dlambda":%e, "dwa":%e, "dwb":%e, "dlm":%e, "dls":%e}',...
        lambda,alpha,beta,sbppLimit, sbplLimit,wa,wb,dlambda,dwa,dwb,dlm,dls);
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
        cell2mat(tmp), demand(i),1,1);
     if i < length(demand)
        fprintf(fid,',\n');
    else
        fprintf(fid,'\n');
    end

end
fprintf(fid,'	]\n}');
fclose(fid)

