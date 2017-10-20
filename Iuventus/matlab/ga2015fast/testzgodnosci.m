%% start
clear all
clc
system('go.cmd')

%%

js=fileread('config.js');
 % netfailsimex(json,N,udtype,ddtype,policy,scale)
 

%exit
[states,times]= createstates(js,10,1,1,1,1);

data=parse_json(js);

limits=cellfun(@(x) x.sbppLimit ,data{1}.components);
primaries=uint64(cellfun(@(x) path2bits(x.path),data{1}.slas));
secondaries=uint64(cellfun(@(x) path2bits(x.backupPath),data{1}.slas));
demands=cellfun(@(x) x.demand,data{1}.slas);

%% 
tic
%pol=sbpp(states,times,primaries,secondaries,demands,limits);
pol=sbpp(states,times,primaries,secondaries,demands,20*ones(size(limits)));
toc
 
tic
[r,lbl]= netfailsimex(js,10,1,1,1,1);
toc

%% 
sim1=sum(r(strcmp(lbl,'SBPPAvail'),:));
%sim1=sum(r(strcmp(lbl,'DedicatedAvail'),:));
%sim1=sum(r(strcmp(lbl,'UnprotectedAvail'),:));

%sim1=sum(r(strcmp(lbl,'DedicatedAvail'),:));
%sim1=demands*(r(strcmp(lbl,'DedicatedAvail'),:));
[mean(sim1), mean(pol)]


% for i=1:5
%     bitset(0,i)
% end