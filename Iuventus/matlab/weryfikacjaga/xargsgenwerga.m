clear
ustmpl = fileread('slacomp-us.mat.json.tmpl');
gertmpl = fileread('slacomp-germany.mat.json.tmpl');
load BestConf.mat
xfid=fopen('params.cfg','w');
for i=1:length(BestConf)
    b=BestConf{i};
    tmpl=[];
    if strcmp(b.Net,'GER')
        tmpl=gertmpl;
    else
        tmpl=ustmpl;
    end
    p=0;
    if strcmp(b.Policy,'cptime')
        p=1;
    else
        p=2;
    end

    fid=fopen([num2str(i),'.js'],'w');
    fprintf(fid,tmpl,b.DNA(4,:));
    fclose(fid);
    fprintf(xfid,'-i %s -o %d.txt -n 100000 -p %d -d 1 \n',[num2str(i),'.js'],i,p);

end
fclose(xfid);