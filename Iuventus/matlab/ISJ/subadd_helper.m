clear
m=matfile('../ograniczenie_workshop/data.mat');

out={};
dists={ 'Exp','Weib', 'Par', 'LogNorm'};
index=1;
argumenty=[0.9, 0.95, 0.99, 0.999];
%mo = matfile('wyniki.mat','Writable',true);
for i=1:size(m,'data',1)
    x=m.data(i,1);
    ulbl =  unique(x.lbl);
    for lbli=1:length(ulbl)

        data=x.data(:,strcmp(ulbl{lbli},x.lbl));
        %uuido=java.util.UUID.randomUUID();
        %uuids=char(uuido.toString());
        name=[dists{x.u},ulbl{lbli},dists{x.d},num2str(index),'-',num2str(i)];
        plot(argumenty,quantile(sum(data,2),argumenty),'r');
        hold on
        plot(argumenty,sum(quantile(data,argumenty),2),'g');
        hold off
        legend VarSumy SumaVar
        title(name);
        print('-dpng',gcf,fullfile('png',[name,'.png']));
        index=index+1;
        disp(index);

    end
end