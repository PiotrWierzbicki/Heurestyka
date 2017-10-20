clear
m=matfile('../ograniczenie_workshop/data.mat');

out={};
dists={ 'Exp','Weib', 'Par', 'LogNorm'};
index=1;
argumenty=[0.9, 0.95, 0.99, 0.999];
%mo = matfile('wyniki.mat','Writable',true);
wyniki={};
nazwy={}

for i=1:size(m,'data',1)
    x=m.data(i,1);
    ulbl =  unique(x.lbl);
	if x.scale ==2
		for lbli=1:length(ulbl)
			data=x.data(:,strcmp(ulbl{lbli},x.lbl));
			
			varsumy=quantile(sum(data,2),argumenty);
			fname=['varsumy',x.net(9:end-7),dists{x.u},ulbl{lbli},dists{x.d},'.txt'];
			tmp=[1:length(argumenty);varsumy]';
			save(fullfile('points',fname),'-ascii','tmp'); 
			
			sumvar=sum(quantile(data,argumenty),2);
            tmp=[1:length(argumenty);sumvar']';
			fname=['sumvar',x.net(9:end-7),dists{x.u},ulbl{lbli},dists{x.d},'.txt'];
            save(fullfile('points',fname),'-ascii','tmp'); 
			
            
			%cvar=cVarNum(,argumenty);
            tmp = sum(data,2);
            cvar=arrayfun(@(arg) cVarNum(tmp,arg), argumenty);
            tmp=[1:length(argumenty);cvar]';
			fname=['cvar',x.net(9:end-7),dists{x.u},ulbl{lbli},dists{x.d},'.txt'];
            save(fullfile('points',fname),'-ascii','tmp'); 

			
			index=index+1;
		end
	end
    
end

%%
i=6;
lbli=9;

%% opis plikow

clear
m=matfile('../ograniczenie_workshop/data.mat');

out={};
dists={ 'Exp','Weib', 'Par', 'LogNorm'};
index=1;
argumenty=[0.9, 0.95, 0.99, 0.999];
%mo = matfile('wyniki.mat','Writable',true);
wyniki={};
nazwy={}
fid=fopen('opispt.txt','w');
for i=1:size(m,'data',1)
    x=m.data(i,1);
    ulbl =  unique(x.lbl);
	if x.scale ==2
		for lbli=1:length(ulbl)
			data=x.data(:,strcmp(ulbl{lbli},x.lbl));
			
			%varsumy=quantile(sum(data,2),argumenty);
			fname=[x.net(9:end-7),dists{x.u},ulbl{lbli},dists{x.d},'.txt'];
            fprintf(fid,'%s, %d, %d\n',fname,i,lbli);

			
			index=index+1;
		end
	end
    
end
fclose(fid);


%% 10

clear
m=matfile('../ograniczenie_workshop/data.mat');

out={};
dists={ 'Exp','Weib', 'Par', 'LogNorm'};
index=1;
argumenty=[0.9, 0.95, 0.99, 0.999];
%mo = matfile('wyniki.mat','Writable',true);
wyniki={};
nazwy={}

for i=1:size(m,'data',1)
    x=m.data(i,1);
    ulbl =  unique(x.lbl);
	if x.scale ==2
		for lbli=1:length(ulbl)
			data=x.data(:,strcmp(ulbl{lbli},x.lbl));
            data=data(:,1:10);
			
			varsumy=quantile(sum(data,2),argumenty);
			fname=['varsumy',x.net(9:end-7),dists{x.u},ulbl{lbli},dists{x.d},'.txt'];
			tmp=[1:length(argumenty);varsumy]';
			save(fullfile('points10',fname),'-ascii','tmp'); 
			
% 			sumvar=sum(quantile(data,argumenty),2);
%             tmp=[1:length(argumenty);sumvar']';
% 			fname=['sumvar',x.net(9:end-7),dists{x.u},ulbl{lbli},dists{x.d},'.txt'];
%             save(fullfile('points',fname),'-ascii','tmp'); 
% 			
%             
% 			%cvar=cVarNum(,argumenty);
%             tmp = sum(data,2);
%             cvar=arrayfun(@(arg) cVarNum(tmp,arg), argumenty);
%             tmp=[1:length(argumenty);cvar]';
% 			fname=['cvar',x.net(9:end-7),dists{x.u},ulbl{lbli},dists{x.d},'.txt'];
%             save(fullfile('points',fname),'-ascii','tmp'); 

			
			index=index+1;
		end
	end
    
end