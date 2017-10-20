%%
%%
teoriaComm

%% teoria z tacasa


momenty=cellfun(@onecomp,params);

srednie=zeros(1, Nsla);
kovariancje=zeros(Nsla, Nsla);

for i=1:Nsla
    msla = momenty(slacomp{i});
   
    x=evarmarkov(msla);
    srednie(i)= tmax*x.b/(x.a+x.b);
    kovariancje(i,i)= tmax*(x.a^2*x.sb^2+x.b^2*x.sa^2)/(x.a+x.b)^3;
end

for i=1:Nsla
    for j=1:Nsla
        wspolne = intersect(slacomp{i}, slacomp{j});
        if i ~= j
            
            if ~isempty(wspolne)
                mm=momenty(wspolne);
                x=evarmarkov(mm);
                kovariancje(i,j) = tmax*(x.a^2*x.sb^2+x.b^2*x.sa^2)/(x.a+x.b)^3;
            end
        end
    end
end

%sredniasumy = sum(srednie);
%varsumy=sum(sum(kovariancje));

sredniasumy = srednie*demand;
varsumy=demand'*kovariancje*demand;

% sredniasumy = mean(XS);
% varsumy=var(XS);


kwantyle=norminv(argumenty,sredniasumy, sqrt(varsumy));
plot(argumenty,kwantyle,'black');

%gamma: srednia = a*b,var=a*b^2 > b=var/mean
gammab=varsumy/sredniasumy;
gammaa=sredniasumy/gammab;
pd = makedist('Gamma','a',gammaa,'b',gammab);
kwantyle2=pd.icdf(argumenty);
plot(argumenty,kwantyle2,'black:','LineWidth',3);

legend('kwantyl sumy(e)', 'kwanty sumy Gaus','suma kwantyli(e)','Ograniczenie analityczne Gaus','Ograniczenie analityczne Gamma', 'Location','NorthWest');

%% export

data=[1:4;f;ff;kwantyle2]'
save -ASCII datacptime.txt data


%% Cvar, polityka1
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
    Tcvarsumy(i)=gamma_cVar(argumenty(i), gammaa, gammab);
end
plot(argumenty, sumacvar,'green');

hold on
plot(argumenty, cvarsumy,'r','LineWidth',3);
plot(argumenty, Tcvarsumy,'black:','LineWidth',3);
legend('suma cvarow','cvar sumy','Ograniczenie analityczne Gamma', 'Location','NorthWest');

%export
data=[1:4;sumacvar;cvarsumy;Tcvarsumy]'
save -ASCII dataCVARcptime.txt data




