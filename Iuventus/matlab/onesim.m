function [ y,t ] = onesim( params,Ncomp ,tmax )
Cx={};
%jedna symulacja
for i=1:Ncomp
    %bo exprnd bierze odwrornosc
%     lambda=params{i}.mean_on;
%     mu=params{i}.mean_off;
    %lambda=30*24*3600;
    %mu=3600;
    %lambda=100;
    %mu=1;

    Cx{i,1}=onecomp(params{i}, tmax, i, Ncomp );
end

x=cell2mat(Cx);
y=sortrows(x);
% startujemy od dzialajacego systemu

tmp=y(1,:);
tmp(isnan(tmp))=0;
y(1,:)=tmp;

%awarie po roku
j=0;
comp=y(end,1);
while y(end-j,1)==comp
    j=j+1;
end
y=y(1:end-j+1,:);


%tic
for i=2:size(y,1)
    for j=2:Ncomp+1
        if isnan( y(i,j) )
            y(i,j) = y(i-1,j);
        end
    end
end
%toc

end

