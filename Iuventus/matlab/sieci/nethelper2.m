function nethelper2(xmlFile, outFile)
%% xslt
% parsowanie plikow  z sieciami
%xmlFile='nobel-germany.xml';
%outFile='slacomp2.mat'

%   nethelper2('nobel-germany.xml', 'slacomp-germany.mat')
%   nethelper2('nobel-us.xml', 'slacomp-us.mat')

xslt(xmlFile,'net2nodes.xslt', 'nodes.txt');
xslt(xmlFile,'net2links.xslt', 'links.txt');
xslt(xmlFile,'net2demands.xslt', 'demands.txt');
xslt(xmlFile,'net2thr.xslt', 'thr.txt');

%% importy
%import pplik�w
importnodes
importlinks
importdemands
importcapacity

fi = (max(x)-min(x))/2;
xx=x;
x=x*-cos(fi); %poprawka geograficzna

cap=cell2mat(thr(:,3))

%%
%Tu tworzona jest macierz s�siedzwtwa
A=zeros(length(x));
linksnumerical=zeros(length(links),2);

for i=1:length(links)
    src=links{i,1};
    dst=links{i,2};
    linksnumerical(i,:)=[name2idx(src,ids),name2idx(dst,ids)];
    A(name2idx(src,ids),name2idx(dst,ids))=1;
end
A=A+A'; % bo lacza sa symetryczne
gplot(A,[x,y],'-o')
axis normal 
for i=1:length(x)
    text(x(i) ,y(i),ids{i},'VerticalAlignment','bottom','HorizontalAlignment','left','FontSize',9)
end
%% routing
%przygotowanie do trasowania

noOfNodes=length(x);
farthestPreviousHop=zeros(noOfNodes,1);
farthestNextHop=zeros(noOfNodes,1);
for i = 1:noOfNodes,
    % initialize the farthest node to be itself;
    farthestPreviousHop(i) = i;     % used to compute the RTS/CTS range;
    farthestNextHop(i) = i;
end;
routes={};
routes2={};
alternatives={};
%% ruch
% wyznaczenie tras i wizualizacja �cie�ek
hold on
colors=hsv(length(demand));
for i=1:length(demand)
    src=name2idx(demandsrc{i},ids);
    dst=name2idx(demanddst{i},ids);
    
    [R1,R2]=suurballe2(A,linksnumerical,src,dst);
    routes{i}=R1;
    routes2{i}=R2;
    alternatives{i}=ProtectionPaths(A,R1,farthestPreviousHop, farthestNextHop); %#ok<SAGROW>
    
    line(x(routes{i}),y(routes{i}), 'Color', 'g','LineWidth', demand(i)/2,'Marker','.','MarkerSize', 20);
    line(x(routes2{i}),y(routes2{i}), 'Color', 'r','LineWidth', demand(i)/2,'Marker','.','MarkerSize', 20);


end
hold off

%% komponenty
%siec do formatu komponentow

slacomp=routes;
slacomp2=routes2;
slacomp3={};
params={};

for i=1:length(x)
    tmp=struct();
%     tmp.mean_on=30*24*3600;
%     tmp.mean_off=3600;
%     
%     tmp.mean_on=3.18e-6
    tmp.type='r';
    params{i}=tmp;
end
lmax=0;
for i=1:length(linksnumerical)
    l=dist(xx(linksnumerical(i,1)),xx(linksnumerical(i,2)),y(linksnumerical(i,1)),y(linksnumerical(i,2)));
    if(l > lmax)
        lmax=l;
    end
end

for i=1:length(linksnumerical)
    tmp=struct();
    tmp.type='l';
    tmp.l=dist(xx(linksnumerical(i,1)),xx(linksnumerical(i,2)),y(linksnumerical(i,1)),y(linksnumerical(i,2)));
    tmp.lmax=lmax;
%     tmp.mean_on=2e8/dist(xx(linksnumerical(i,1)),xx(linksnumerical(i,2)),y(linksnumerical(i,1)),y(linksnumerical(i,2))); %ok miesiaca
%     tmp.mean_off=2*3600; %2h
    params{end+1}=tmp;
end


slacomp=cellfun(@(arg) SlacompFromPath(arg,linksnumerical,length(x)),routes,  'UniformOutput', false);
slacomp2=cellfun(@(arg) SlacompFromPath(arg,linksnumerical,length(x)),routes2,  'UniformOutput', false);
alternativeslacomp=cellfun(@(arg1)cellfun(@(arg2) SlacompFromPath(arg2,linksnumerical,length(x)),arg1,  'UniformOutput', false),...
    alternatives, 'UniformOutput', false);

save(outFile, 'slacomp', 'slacomp2', 'params', 'demand', 'alternativeslacomp','cap','noOfNodes')

