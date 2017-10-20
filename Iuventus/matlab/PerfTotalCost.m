clear

lambdar=paramFromEnv('LAMBDAR',3.18e-7);
alpha=paramFromEnv('ALPHA',2.3);
%alpha=paramFromEnv('ALPHA',0.8);
betam=paramFromEnv('BETAM',60);
plik=paramFromEnv('PLIK','plik2.mat');

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

%% remove routers
slacomp=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp,'UniformOutput', false);
slacomp2=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp2,'UniformOutput', false);

for i=1:length(alternativeslacomp)
    alternativeslacomp{i}=cellfun(@(arg) linksOnly(arg,noOfNodes),alternativeslacomp{i},'UniformOutput', false);
end

%cap = zeros(size(cap)) + max(GetCapacity(slacomp,cap,demand,noOfNodes));
%pasmo potrzebne do zrobienia sbpp
cap = GetSBPPCapacity(slacomp2,cap,demand,noOfNodes)+1;
Nsla=length(slacomp);
Ncomp = length(params);
Nlink=length(cap);

vektor=rand(4,Nsla);
vektor= bsxfun(@eq ,vektor,max(vektor));

% vektor = zeros(4,Nsla);
% vektor(4,:)=ones(1,Nsla);
% vektor=logical(vektor);

%% test starej implementacji
tic
tc = TotalCost(slacomp, slacomp2, alternativeslacomp,demand,vektor,cap,noOfNodes);
t1=toc

%% nowa implementacja
slamat=zeros(Nsla,Nlink);
sbppmat=zeros(Nsla,Nlink);
for i=1:length(slacomp)
    slamat(i,slacomp{i}-noOfNodes)=1;
    sbppmat(i,slacomp2{i}-noOfNodes)=demand(i);
end

slamat2=zeros(Nsla,Nlink);
for i=1:length(slacomp2)
    slamat2(i,slacomp2{i}-noOfNodes)=1;
end
% slamat3=zeros(Nsla,Nlink,length(alternativeslacomp));
% 
% for j=1:length(alternativeslacomp)
%     slatmp=alternativeslacomp{j};
%     for i=1:length(slatmp)
%         slatamat3(i,slatmp{i}-noOfNodes,j)=1;
%     end
% end

CostDedicated=sum(slamat2,2).*demand;
CostLinkDedicated=zeros(size(CostDedicated));
for i=1:size(CostLinkDedicated,1)
    tmp=[]; % tu jest zapas
    tmpsla=alternativeslacomp{i};
    for j=1:length(tmpsla)
        tmp=[tmp,tmpsla{j}];
    end
    tmp = setdiff(tmp,slacomp{i}); % bo placimy tylko za te, ktore ida poza sciezka podstawowa
    CostLinkDedicated(i) = length(unique(tmp))*demand(i);
end

%% weryfikacja (potrzeba tylko sbppmat,CostDedicated i CostLinkDedicated)
% przyspieszenie ~300 x
tic
tc2 = sum(max(sbppmat(vektor(4,:)',:)))+ vektor(2,:)*CostDedicated + vektor(3,:)*CostLinkDedicated;
t2=toc
tc
tc2

t1/t2

