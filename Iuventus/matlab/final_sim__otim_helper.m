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

optPlik=paramFromEnv('OPT_PLIK','oplik.mat');

load(optPlik);

tmax=12*30*24*3600;%rok

slacompName=paramFromEnv('SLACOMP','sieci/slacomp-germany.mat');
load(slacompName);
policy=paramFromEnv('POLICY','cptime');
th=paramFromEnv('POL_TH',0);
global isPareto;
isPareto=boolean(paramFromEnv('PARETO',1));
qq=boolean(paramFromEnv('EXIT_MATLAB',0));
protection=boolean(paramFromEnv('PROTECTION',1));
w=boolean(paramFromEnv('W',0.3));

% protections=rand(4,121);protections=bsxfun(@eq,protections,max(protections));
% save oplik.mat protections

%% remove routers
slacomp=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp,'UniformOutput', false);
slacomp2=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp2,'UniformOutput', false);

for i=1:length(alternativeslacomp)
    alternativeslacomp{i}=cellfun(@(arg) linksOnly(arg,noOfNodes),alternativeslacomp{i},'UniformOutput', false);
end

%cap = zeros(size(cap)) + max(GetCapacity(slacomp,cap,demand,noOfNodes));
%pasmo potrzebne do zrobienia sbpp
cap = GetSBPPCapacity(slacomp2(protections(4,:)),cap,demand(protections(4,:)),noOfNodes)+1;
%% simulate
Ncomp = max(cellfun(@(x) max(x),slacomp));
N=100000;
N=1000;
Nsla=length(slacomp);
X={};
for i=1:2
    for j=1:4
        X{i,j}=zeros(N,Nsla);
    end
end

for i=1:N
    [y]=onesim( params,Ncomp,tmax);
    t=y(:,1);
    [sbppIDX] = SBPPidx(y,slacomp(protections(4,:)),slacomp2(protections(4,:)),cap,demand(protections(4,:)),noOfNodes,w);
    for k=1:Nsla
        
        %bez protekcji    
        idx=sum(y(:,slacomp{k}+1),2)>0; %+1 bo czasy w 1 kolumnie
        idx2=find(idx == 0);% awaria
        dt=t(idx2(2:end))-t(idx2(1:end-1)+1);
        X{1,1}(i,k)=compensationPolicy(dt,tmax,'cptime',th);
        X{2,1}(i,k)=compensationPolicy(dt,tmax,'cpfail',th);

        %zapasowa sciezka 1+1
        idx2=find((idx & (sum(y(:,slacomp2{k}+1),2)>0)) == 0);% awaria
        dt=t(idx2(2:end))-t(idx2(1:end-1)+1);
        X{1,2}(i,k)=compensationPolicy(dt,tmax,'cptime',th);
        X{2,2}(i,k)=compensationPolicy(dt,tmax,'cpfail',th);

        %1+1L
        v=alternativeslacomp{k};
        % przynajmniej 1 musi dzialac
        for pIndex=1:length(v)
            idx = idx & (sum(y(:,v{pIndex}+1),2)>0);
        end
        idx2=find(idx == 0);% awaria
        dt=t(idx2(2:end))-t(idx2(1:end-1)+1);
        X{1,3}(i,k)=compensationPolicy(dt,tmax,'cptime',th);
        X{2,3}(i,k)=compensationPolicy(dt,tmax,'cpfail',th);
        
        
    end
    for k=1:sum(protections(4,:))
        %SBPP
        idx2=find(sbppIDX(:,k) == 0);% awaria
        dt=t(idx2(2:end))-t(idx2(1:end-1)+1);
        X{1,4}(i,k)=compensationPolicy(dt,tmax,'cptime',th);
        X{2,4}(i,k)=compensationPolicy(dt,tmax,'cpfail',th);

    end
    i       
%     X{1,2} == X{1,4};
%     sum(ans(:))/length(ans(:))

end

%% analiza
Xopt={};
riskt=zeros(N,1);
riskf=zeros(N,1);

for i=1:4
    %for j=1:2
        %Xopt{j,i}=X{j,i}(:,protections(i,:))*demand(protections(i,:)');
        
    %end
    riskt = riskt + X{1,i}(:,protections(i,:))*demand(protections(i,:)');
    riskf = riskf + X{2,i}(:,protections(i,:))*demand(protections(i,:)');
end

clear dt t i y k idx idx2 sbppIDX
save(plik,'-v7.3')
if qq
    exit
end
