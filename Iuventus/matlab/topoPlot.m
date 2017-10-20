function [ output_args ] = topoPlot( slacomp )
Ncomp = max(cellfun(@(x) max(x),slacomp));
Nsla=length(slacomp);

fi=linspace(0,2*pi,Ncomp+1);
fi=fi(1:end-1);
colors=lines(Nsla);
lws = linspace(20,6,Nsla);

plot(sin(fi),cos(fi),'.')
hold on
for i=1:Nsla
    line(sin(fi(slacomp{i})),cos(fi(slacomp{i})), 'Color', colors(i,:),'LineWidth', lws(i),'Marker','.','MarkerSize', 20);
end
plot(sin(fi),cos(fi),'o','MarkerSize', 21,'MarkerFaceColor',[0,0,0])
hold off
% A=rand(Ncomp,Ncomp) > 0.8;
% gplot(A,[sin(fi);cos(fi)]','r-*');
% hold on
% A=rand(Ncomp,Ncomp) > 0.8;
% gplot(A,[sin(fi);cos(fi)]','g-*');
axis square
end

