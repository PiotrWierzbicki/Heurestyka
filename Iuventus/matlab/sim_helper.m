%% zmienne ze srodowiska
clear
global lambdar;
global alpha;
global betam;

lambdar=paramFromEnv('LAMBDAR',3.18e-7);
alpha=paramFromEnv('ALPHA',2.3);
%alpha=paramFromEnv('ALPHA',0.8);
betam=paramFromEnv('BETAM',60);
plik=paramFromEnv('PLIK','plik2.mat');

tmax=12*30*24*3600;%rok

slacompName=paramFromEnv('SLACOMP','sieci/slacomp.mat');
load(slacompName);
policy=paramFromEnv('POLICY','cptime');
th=paramFromEnv('POL_TH',0);
global isPareto;
isPareto=boolean(paramFromEnv('PARETO',1));
qq=boolean(paramFromEnv('EXIT_MATLAB',0));
protection=boolean(paramFromEnv('PROTECTION',1));


%% simulate
Ncomp = max(cellfun(@(x) max(x),slacomp));
N=100000;
%N=1000;
Nsla=length(slacomp);
X=zeros(N,Nsla);

for i=1:N
    [y]=onesim( params,Ncomp,tmax);
    t=y(:,1);
    for k=1:Nsla
        idx=sum(y(:,slacomp{k}+1),2)>0; %+1 bo czasy w 1 kolumnie
        
        if protection
            idx_prot=sum(y(:,slacomp2{k}+1),2)>0; %+1 bo czasy w 1 kolumnie
            idx2=find((idx & idx_prot) == 0);% awaria
        else
            idx2=find(idx == 0);% awaria
        end
        dt=t(idx2(2:end))-t(idx2(1:end-1)+1);
        X(i,k)=compensationPolicy(dt,tmax,policy,th);
    end
    i
end
clear dt t i y k idx idx2 
save(plik,'-v7.3')
if qq
    exit
end
