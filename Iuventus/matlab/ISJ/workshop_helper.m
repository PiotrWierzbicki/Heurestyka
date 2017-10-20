%%
clear
netName='slacomp-germany.mat.js';
netName='slacomp-us.mat.js';
json=parse_json( urlread(['file:///E:\\Iuventus\\matlab\\sieci\\',netName]));
load ..\ograniczenie_workshop\out.mat
javaclasspath ../../java/NetworkMarkov/dist/NetworkMarkov.jar
%%
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

scale = 2;
thr = min([moments.b])* scale

%% Nowa teoria
close all
srednie=zeros(1, Nsla);
kovariancje=zeros(Nsla, Nsla);
ttmax=tmax;
%thr=0;
for i=1:Nsla
    msla = moments(paths{i});
    x=evarmarkov3(msla,thr);
    srednie(i)= ttmax*x.b*x.en;
    kovariancje(i,i)= ttmax*(x.en*x.sb^2+x.b^2*x.vn);
end

for i=1:Nsla
    for j=i+1:Nsla
        wspolne = intersect(paths{i}, paths{j});
        if ~isempty(wspolne)
            mm=moments(wspolne);
            %length(mm)
            x=evarmarkov3(mm, thr);
            kovariancje(i,j) =  ttmax*(x.en*x.sb^2+x.b^2*x.vn);
        end

    end
end
kovariancje = kovariancje +kovariancje' -diag(diag(kovariancje));
sredniasumy2 = srednie*demands';
varsumy2=demands*kovariancje*demands';

gammab=varsumy2/sredniasumy2;
gammaa=sredniasumy2/gammab;
pd = makedist('Gamma','a',gammaa,'b',gammab);

lnsigma=sqrt(log(varsumy2/sredniasumy2^2+1));
lnmu=log(sredniasumy2)-(lnsigma^2)/2;

pd = makedist('Lognormal','mu',lnmu,'sigma',lnsigma);

kwantyle22=pd.icdf(argumenty)
mat2str(kwantyle22)

idx =  strcmp(netName,out(:,4)) & ...
    cellfun(@(x)x==scale ,out(:,3)) & ...
    strcmp('UnprotectedSnowball',out(:,5));

%strcmp('UnprotectedSnowball',out(:,5));
%strcmp('UnprotectedFixedRestartCost',out(:,5));
% idx =  strcmp(netName,out(:,4)) & ...
%     cellfun(@(x)x==1 ,out(:,3)) & ...
%     strcmp('DedicatedAvail',out(:,5));


out2=out(idx,:);
figure
hold on
cc=lines(12);
%for i=1:size(out2,1)
for i=[1:2]
    plot(out2{i,6},'Color',cc(i,:))
end
plot(kwantyle22,'Color','Black','LineWidth',2.1);

%plot(out2{1,6},'Color',cc(1,:))

%plot(kwantyle22,'Color','Black','LineWidth',2.1);
%plot(out2{1,7},'Color',cc(2,:))
legend(strcat(out2(:,1),out2(:,2)))
