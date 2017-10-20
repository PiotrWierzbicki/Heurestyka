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
%numer=40;
%numer2=18;

numer=25;
numer2=8;

protslacov(numer, numer2,paths, backupPaths,moments,tmax ,'avail')
cov(data(:,[numer,numer2]))
%%
[ esla, varsla ] = protslastat( numer,paths, backupPaths,moments,tmax ,'avail')
mean(data(:,[numer]))
var(data(:,[numer]))


%mean(data(:,strcmp('DedicatedAvail',lbl)))