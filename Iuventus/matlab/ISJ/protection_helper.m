%% wczytanie mata
clear
m=matfile('../ograniczenie_workshop/data.mat');
x=m.data(2,1);
data=x.data(:,strcmp('DedicatedAvail',x.lbl));

%% parsowanie danych

json=parse_json( urlread(['file:///E:\\Iuventus\\matlab\\sieci\\',x.net]));
load ..\ograniczenie_workshop\out.mat

%% test maly
% clear
% x=struct();
% x.scale=1;
% data= load('protekcja\slacomp-germany.mat.jstest.txt');
% lbl=importdata('protekcja\slacomp-germany.mat.jstest.txt.lbl');
% json=parse_json( urlread(['file:///e:\\Iuventus\\matlab\\ISJ\\protekcja\\slacomp-germany.mat.js']));


%% parsowanie
javaclasspath ../../java/NetworkMarkov/dist/NetworkMarkov.jar
demands=cellfun(@(arg) arg.demand,json{1}.slas);
%moments=cellfun(@(arg) struct('a',1/arg.ulambda,'sa',1/arg.ulambda,'b',1/arg.dlambda,'sb',1/arg.dlambda),json{1}.components);
moments=cellfun(@json2moment,json{1}.components);
paths=cellfun(@(arg) cell2mat(arg.path),json{1}.slas,'UniformOutput',false);
backupPaths=cellfun(@(arg) cell2mat(arg.backupPath),json{1}.slas,'UniformOutput',false);
Nsla = length(paths);
tmax = 12*30*24*3600;
argumenty=[0.9, 0.95, 0.99, 0.999];


%% Policy
%   thr = min_element(1.0 /dlambda)*scale
% * Cont 1
% * Thre x>thr ? x : 0.0
% * LinearCost demand*x
% * FixedRestartCost demand*x + demand*thr
% * Snowball demand/thr*$$x^2$$
% 

thr = min([moments.b])* x.scale;

%% Playground
%clear x
%clear m
numer=40;
pp=paths{numer};
bp = backupPaths{numer};
tp=unique([pp,bp]);

msla = moments(tp);


[pi,~]=find(bsxfun(@eq,tp',pp));
[bi,~]=find(bsxfun(@eq,tp',bp));

n=length(msla);
k=3;
if k>n
    k=n;
end
s=networkmarkov.NetworkMarkov(n,k);
lambdas=arrayfun(@(arg) 1/arg.a,msla);
mus=arrayfun(@(arg) 1/arg.b,msla);

x=s.makeQ(lambdas, mus);

d=sum(arrayfun(@(arg) nchoosek(n,arg),0:k));
Q=sparse(double(x.iidx)+1,double(x.jidx)+1,x.values,d,d);
Q=Q-diag(sum(Q,2));

workingStates = s.getWorkingStatesInProtection(pi-1,bi-1)+1;
failedStates = setdiff(1:d,workingStates);

D=diag(Q);
Pemb = speye(size(Q))-spdiags(1./D,0,d,d)*Q;
pi=stableMarkovChaindistribution(Pemb);


% Prwdopobienstwo rozkladu przy wejsciach do grupy stanów
% zakaldam, ze stan jest liczony przed przeskokiem
Pingrupa= pi(failedStates)/sum(pi(failedStates));


T=Q(failedStates,failedStates);
r=Q(failedStates,workingStates);

m1=full(Pingrupa*(sum(T^2\r,2)));
m2=full(Pingrupa*(-2*sum(T^3\r,2)));

vm=m2-m1^2;

%full(Q(3:end,3:end)^2\Q(3:end,1:2));
%full(Q(workingStates,workingStates)^2\Q(workingStates,failedStates));
Pinniegrupa= pi(workingStates)/sum(pi(workingStates));

mu1=Pinniegrupa*(sum(full(Q(workingStates,workingStates)^2\Q(workingStates,failedStates)),2));
mu2=Pinniegrupa*(sum(-2*full(Q(workingStates,workingStates)^3\Q(workingStates,failedStates)),2));
sigma= sqrt(mu2-mu1^2); %variancja
%m1/(mu1+m1)

%pi=MMPP_Pi(Q);
%sum(pi(failedStates))
tmax/mu1*m1
mean(data(:,numer))

tmax/mu1*vm + m1^2*(sigma^2*tmax/mu1^3)
var(data(:,numer))

%mean(data(:,strcmp('DedicatedAvail',lbl)))