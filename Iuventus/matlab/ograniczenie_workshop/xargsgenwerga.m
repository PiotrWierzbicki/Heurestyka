clear
% g++ -O2 -std=gnu++11   -o ../../../matlab/ograniczenie_workshop/netfailsim netfailsim.cpp components.cpp
%[krusek@pbz netfailsim]$ pwd
%/home/krusek/Iuventus/Iuventus/cpp/netfailsim/netfailsim
%xargs -a params.txt  -n 14 -P 15 ./netfailsim
filenames={'slacomp-us.mat.js','slacomp-germany.mat.js'};
scales=[0.5,1.0,2];
%netfailsim -i config.json -o out.txt -n N -p policy[1 avail, 2 cont, 3 thre 4 snoball] -u up_time_dist[1 Exp, 2 Weib] -d down_time_dist[1 Exp, 2 Weib, 3 Par, 4LogNorm] -h [thr scale]
xfid=fopen('params.cfg','w');
for u=1:2
    for d=1:4
        for s=1:length(scales)
            for i=1:length(filenames)
                fname=[filenames{i},'_',num2str(u),'_',num2str(d),'_',num2str(s),'_.txt'];
                fprintf(xfid,'-i %s -o %s -n 100000 -p 1 -u %d -d %d -h %f \n',filenames{i},fname,u,d, scales(s))
            end
        end
    end
end
fclose(xfid);