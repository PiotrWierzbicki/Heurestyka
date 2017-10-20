%jeden komponen
%http://sndlib.zib.de/home.action
tic 

Cx={};
tmax=12*30*24*3600;%rok
%tmax=2*12*30*24*3600;%rok
%tmax=10000;
slacomp={...
    [1,2,3,4],...
    [1,5,6],...
    [2,3,1,4],...
    [5,6],...
    [6,7,1]...
    [8,9]...
    };
% slacomp={...
%     [1],...
%     };
load sieci/slacomp.mat
%load siecinobel-us/slacomp.mat
% to jest do testow
%
% slacomp={...
%     [1,2,3,4],...
%     [1,2,5,6],...
%     };
% 
% slacomp={...
%     [1,2,3],...
%     [1,3,6],...
%     [1,4,5,6],...
%     [4,5,6],...
%     [1,2,5,6],...
%     };
% 
% demand=[1;1;1;1;1];
% params=params([1:3,41,42,43]);
% 

% slacomp={...
%     [1,2],...
%     [2,3],...
%     };
% 
% demand=[1;1];
% params=params([1:3]);

Ncomp = max(cellfun(@(x) max(x),slacomp));
N=100000;
%N=10000;
%N=10000;
Nsla=length(slacomp);
X=zeros(N,Nsla);

mode='2';




% parametry z Kuusela i Norros
% router : wykladniczy o sredniej lambd=3.14e6 s = 872h
%topoPlot(slacomp)
%% zmienne ze srodowiska

global lambdar;
global alpha;
%alpha = 0.7;
global betam;

lambdar=str2double(getenv('LAMBDAR'));
alpha=str2double(getenv('ALPHA'));
betam=str2double(getenv('BETAM'));
plik=getenv('PLIK');

%%

for i=1:N
    [y]=onesim( params,Ncomp,tmax);
    t=y(:,1);
    for k=1:Nsla
        idx=sum(y(:,slacomp{k}+1),2)>0; %+1 bo czasy w 1 kolumnie
        idx2=find(idx==0);
        dt=t(idx2(2:end))-t(idx2(1:end-1)+1);
        X(i,k)=compensationPolicy(dt,tmax,'cpfail');
    end
    i
end
%X=X*diag(demand);
corsum=corr(X)
%save corsum.mat corsum
%save X100kfinalgerpol1.mat X
save(plik,'X','-v7.3')

XS = sum(X,2);


