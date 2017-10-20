%%
teoriaComm

%% teoria dla polityki 2

momenty=cellfun(@onecomp,params);

srednie=zeros(1, Nsla);
kovariancje=zeros(Nsla, Nsla);

for i=1:Nsla
    msla = momenty(slacomp{i});
    srednie(i)= sum(arrayfun(@(x) 1/x.a,msla))*tmax;
    kovariancje(i,i)= srednie(i);
end

for i=1:Nsla
    for j=1:Nsla
        wspolne = intersect(slacomp{i}, slacomp{j});
        if i ~= j
            
            if ~isempty(wspolne)
                mm=momenty(wspolne);
                kovariancje(i,j) = sum(arrayfun(@(x) 1/x.a,mm))*tmax;
            end
        end
    end
end

sredniasumy = sum(srednie);
varsumy=sum(sum(kovariancje));

sredniasumy = srednie*demand;
varsumy=demand'*kovariancje*demand;

% sredniasumy = mean(XS);
% varsumy=var(XS);


kwantyle=norminv(argumenty,sredniasumy, sqrt(varsumy));
plot(argumenty,kwantyle,'black');

%% export2

data=[1:4;f;ff;kwantyle]'
save -ASCII datacpfail.txt data

%% Cvar, polityka2
figure;

cvarsumy=zeros(size(argumenty));

for i=1:length(argumenty)
    cvarsumy(i)=cVarNum(XS,argumenty(i));
end

cvary=zeros(Nsla,length(argumenty));

for j=1:Nsla
    for i=1:length(argumenty)
        cvary(j,i) = cVarNum(XW(:,j),argumenty(i));
    end
end
sumacvar = sum(cvary);


Tcvarsumy=zeros(size(argumenty));

for i=1:length(argumenty)
    Tcvarsumy(i)=gaussian_cVar(argumenty(i), sredniasumy, sqrt(varsumy));
end
plot(argumenty, sumacvar,'green');

hold on
plot(argumenty, cvarsumy,'r','LineWidth',3);
plot(argumenty, Tcvarsumy,'black:','LineWidth',3);
legend('suma cvarow','cvar sumy','Ograniczenie analityczne Gamma', 'Location','NorthWest');

%%export
data=[1:4;sumacvar;cvarsumy;Tcvarsumy]'
save -ASCII dataCVARcpfail.txt data


