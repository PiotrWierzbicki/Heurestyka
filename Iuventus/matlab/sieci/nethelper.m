%% xslt
% parsowanie plikow  z sieciami
xslt('nobel-germany.xml','net2nodes.xslt', 'nodes.txt');
xslt('nobel-germany.xml','net2links.xslt', 'links.txt');
xslt('nobel-germany.xml','net2demands.xslt', 'demands.txt');

%% importy
%import pplik�w
importnodes
importlinks
importdemands

fi = (max(x)-min(x))/2;
xx=x;
x=x*-cos(fi); %poprawka geograficzna

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
    
    routes{i}=dijkstra(noOfNodes,1./A,src,dst, farthestPreviousHop, farthestNextHop);
    %wywalamy wybrane
    r = routes{i};
    nNode=size(A,1);
    A2=A;
    for j=2:length(r)-1
        A2(:,r(j))=zeros(nNode,1);
        A2(r(j),:)=zeros(1,nNode);
    end
    routes2{i}=dijkstra(noOfNodes,1./A2,src,dst, farthestPreviousHop, farthestNextHop); %#ok<SAGROW>
    %line(x([src,dst]),y([src,dst]), 'Color', colors(i,:),'LineWidth', demand(i),'Marker','.','MarkerSize', 20);
    %line(x(routes{i}),y(routes{i}), 'Color', colors(i,:),'LineWidth', demand(i)/2,'Marker','.','MarkerSize', 20);
    alternatives{i}=ProtectionPaths(A,r,farthestPreviousHop, farthestNextHop); %#ok<SAGROW>
    
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

for i=1:length(demand)
    li=[];
    for j=1:length(slacomp{i})-1
        %get id of link j,j+1
        src=slacomp{i}(j);
        dst=slacomp{i}(j+1);
        j
        
        linkid = find((linksnumerical(:,1)==src & linksnumerical(:,2)==dst)|...
            (linksnumerical(:,1)==dst & linksnumerical(:,2)==src));
        li=[li,linkid];
        
        
    end
    % doid noda dodajemy id wezlow
    slacomp{i}=[slacomp{i},li+length(x)];
    
    %zapasowe
    li2=[];
    for j=1:length(slacomp2{i})-1
        %get id of link j,j+1
        src=slacomp2{i}(j);
        dst=slacomp2{i}(j+1);
        j
        
        linkid = find((linksnumerical(:,1)==src & linksnumerical(:,2)==dst)|...
            (linksnumerical(:,1)==dst & linksnumerical(:,2)==src));
        li2=[li2,linkid];
        
        
    end
    
    % doid noda dodajemy id wezlow
    slacomp2{i}=[slacomp2{i},li2+length(x)];
    
end

save slacomp.mat slacomp slacomp2 params demand

