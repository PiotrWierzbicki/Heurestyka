out='slacomp-germany.js'
Slacomp2JasonNoRouterF('../sieci/slacomp-germany.mat',3.18e-7,2.3, 60,0.8,out)

% czytamy konfig
js=fileread(out);
data=parse_json(js);



%% Przygotowujemy stany
N=100000; % liczba iteracji
[states,times]= createstates(js,N,1,3,1,1); 

% [r,lbl]= netfailsimex(js,N,1,3,1,1);% Exp,Par,Avail
% 
% unprotected=r(strcmp(lbl,'UnprotectedAvail'),:);
% dedicated=r(strcmp(lbl,'DedicatedAvail'),:);
% ldedicated=r(strcmp(lbl,'LinkDedicatedAvail'),:);
% clear r

%% parametry do sbpp
limits=cellfun(@(x) x.sbppLimit ,data{1}.components); %limity na pasmo sbpp
primaries=uint64(cellfun(@(x) path2bits(x.path),data{1}.slas));
secondaries=uint64(cellfun(@(x) path2bits(x.backupPath),data{1}.slas));

%ustawiamy  na 0 tam gdzie nie ma sbpp
demands=cellfun(@(x) x.demand,data{1}.slas);

sbppcost=sbpp(states,times,primaries,secondaries,demands,limits);


%%
for i=1:1000
    CV(i) = cVarNum(sbppcost(1+(i-1)*100:i*100), 0.95);
    VAR(i) = quantile(sbppcost(1+(i-1)*100:i*100), 0.95);
end
    
    
    
    


