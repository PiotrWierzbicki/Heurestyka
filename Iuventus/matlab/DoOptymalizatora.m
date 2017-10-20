%%ladowanie
clear
load ../optim-germanyi-sbpp5

%% 

X=cellfun(@(arg) mean(arg*diag(demand)),X,'UniformOutput',false);
%% export
fid=fopen('../Xtime.txt','w');
fprintf(fid,'risk=[');
for i=1:4
    fprintf(fid,'%s',strrep(mat2str(X{1,i}),' ',','));
    if i < 4
       fprintf(fid,','); 
    end
end
fprintf(fid,']'); 
fclose(fid);