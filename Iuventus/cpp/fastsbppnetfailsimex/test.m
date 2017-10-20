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
pol=sbpp(states,times,primaries,secondaries,demands,limits,'linear');
toc