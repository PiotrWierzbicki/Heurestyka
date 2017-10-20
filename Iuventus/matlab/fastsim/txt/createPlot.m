clear
load out.mat
data=cell2mat(out);
nets={'slacomp-germany.mat', 'slacomp-us.mat'}
statNames={'UnprotectedStatsColector','DedicatedProtectionColector','LinkDedicatedProtectionColector',' SBPPColector',' SBLPColector'};
step = length(statNames);
policyNames={'AvailPolicy','ContPolicy','ThrePolicy' };
distnames={'Exp','Weib'};

% tu zmieniamy zeby miec inne wykresy
idx=arrayfun(@(arg) ...
    strcmp(arg.net,'slacomp-germany.mat') &...
    strcmp(arg.policy,'ContPolicy') &...
    strcmp(arg.stat,'UnprotectedStatsColector') &...
    strcmp(arg.distrib,'Exp')...
    ,data);

as=[data(idx).a];
qs=[data(idx).qs];
sq=[data(idx).sq];
rms=(sq-qs)./qs;
plot(as,rms);

%do tikza

% pt=[as;rms]';
% save -ascii plik.txt pt
for n=1:length(nets)
    for i=1:length(statNames)
        for j=1:length(policyNames)
            for k=1:length(distnames)
                idx=arrayfun(@(arg) ...
                    strcmp(arg.net,nets{n}) &...
                    strcmp(arg.policy,policyNames{j}) &...
                    strcmp(arg.stat,statNames{i}) &...
                    strcmp(arg.distrib,distnames{k})...
                    ,data);
                as=[data(idx).a];
                qs=[data(idx).qs];
                sq=[data(idx).sq];
                rms=(sq-qs)./qs;
                %figure
                plot(as,rms);
                title([nets{n},policyNames{j},statNames{i},distnames{k}])
                pt=[as;rms]';
                save('-ascii', ['b60',nets{n},policyNames{j},statNames{i},distnames{k},'.txt'], 'pt');

                %print('-dpng',[nets{n},policyNames{j},statNames{i},distnames{k},'.png']);
            end
        end
    end
end