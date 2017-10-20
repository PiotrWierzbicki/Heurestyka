%%
clear
netName='slacomp-germany.mat.js';
%netName='slacomp-us.mat.js';
json=parse_json( urlread(['file:///E:\\Iuventus\\matlab\\sieci\\',netName]));
load ograniczenie_workshop\out.mat

%%
demands=cellfun(@(arg) arg.demand,json{1}.slas);
%moments=cellfun(@(arg) struct('a',1/arg.ulambda,'sa',1/arg.ulambda,'b',1/arg.dlambda,'sb',1/arg.dlambda),json{1}.components);
moments=cellfun(@json2moment,json{1}.components);
paths=cellfun(@(arg) cell2mat(arg.path),json{1}.slas,'UniformOutput',false);
backupPaths=cellfun(@(arg) cell2mat(arg.backupPath),json{1}.slas,'UniformOutput',false);
Nsla = length(paths);
tmax = 12*30*24*3600;
argumenty=[0.9, 0.95, 0.99, 0.999];
%% teria

srednie=zeros(1, Nsla);
kovariancje=zeros(Nsla, Nsla);

for i=1:Nsla
    msla = moments(paths{i});
   
    x=evarmarkov(msla);
    srednie(i)= tmax*x.b/(x.a+x.b);
    kovariancje(i,i)= tmax*(x.a^2*x.sb^2+x.b^2*x.sa^2)/(x.a+x.b)^3;
end

for i=1:Nsla
    for j=1:Nsla
        wspolne = intersect(paths{i}, paths{j});
        if i ~= j
            
            if ~isempty(wspolne)
                mm=moments(wspolne);
                x=evarmarkov(mm);
                kovariancje(i,j) = tmax*(x.a^2*x.sb^2+x.b^2*x.sa^2)/(x.a+x.b)^3;
            end
        end
    end
end

%sredniasumy = sum(srednie);
%varsumy=sum(sum(kovariancje));

sredniasumy = srednie*demands';
varsumy=demands*kovariancje*demands';

% sredniasumy = mean(XS);
% varsumy=var(XS);


kwantyle=norminv(argumenty,sredniasumy, sqrt(varsumy));
gammab=varsumy/sredniasumy;
gammaa=sredniasumy/gammab;
pd = makedist('Gamma','a',gammaa,'b',gammab);
kwantyle2=pd.icdf(argumenty)

%% Nowa teoria
close all
srednie=zeros(1, Nsla);
kovariancje=zeros(Nsla, Nsla);
ttmax=tmax;

for i=1:Nsla
    msla = moments(paths{i});
    %modyfikacja
%     ttmax=timeOnProtection(moments,paths{i},backupPaths{i},tmax);
%     msla = moments(backupPaths{i});
    %length(msla)
    %modyfikacja
    x=evarapprox(msla);
    srednie(i)= ttmax*x.b*x.en;
    kovariancje(i,i)= ttmax*(x.en*x.sb^2+x.b^2*x.vn);
end

for i=1:Nsla
    for j=1:Nsla
        wspolne = intersect(paths{i}, paths{j});
        %modyfikacja
%         ttmax=max([timeOnProtection(moments,paths{i},backupPaths{i},tmax),...
%             timeOnProtection(moments,paths{j},backupPaths{j},tmax)]);
%         wspolne = intersect(backupPaths{i}, backupPaths{j});
        %modyfikacja
        if i ~= j
            
            if ~isempty(wspolne)
                mm=moments(wspolne);
                %length(mm)
                x=evarapprox(mm);
                kovariancje(i,j) =  ttmax*(x.en*x.sb^2+x.b^2*x.vn);
            end
        end
    end
end

sredniasumy2 = srednie*demands';
varsumy2=demands*kovariancje*demands';

gammab=varsumy2/sredniasumy2;
gammaa=sredniasumy2/gammab;
pd = makedist('Gamma','a',gammaa,'b',gammab);
kwantyle22=pd.icdf(argumenty)
mat2str(kwantyle22)

idx =  strcmp(netName,out(:,4)) & ...
    cellfun(@(x)x==1 ,out(:,3)) & ...
    strcmp('DedicatedLinearCost',out(:,5));

% idx =  strcmp(netName,out(:,4)) & ...
%     cellfun(@(x)x==1 ,out(:,3)) & ...
%     strcmp('DedicatedAvail',out(:,5));


out2=out(idx,:);
figure
hold on
cc=lines(12);
for i=1:size(out2,1)
    plot(out2{i,6},'Color',cc(i,:))
end
plot(kwantyle22,'Color','Black','LineWidth',2.1);
legend(strcat(out2(:,1),out2(:,2)))
%%
% ulambda=1./3.180000e-07;
% uwa=3.500000e-01;
% uwb=6.252861e+05;
% 
% x=0.1*ulambda:10:1.8*ulambda;plot(x/ulambda,wblpdf(x,uwb,uwa)./(1-wblcdf(x,uwb,uwa)),x/ulambda,1./ulambda*ones(size(x)))
% hold on
% x=0:0.0010:0.2;
% plot(x/ulambda,uwa/uwb*(x./uwb).^(uwa-1),'r--');
% xlabel('t/tmean')
% ylabel('failure rate')
% legend('Weibul rate', 'Exp rate')

%%
%uwa=1.3
% x=0:0.0010:0.2;
% plot(x/ulambda,uwa/uwb*(x./uwb).^(uwa-1),'r--');