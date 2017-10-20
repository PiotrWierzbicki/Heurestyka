%% Dobranie parametrów

dpa=[0.9,1,1+logspace(-3,0,2),linspace(3,4,2)];
dpb=linspace(1,100,2);
dpb=[60];

%pd = makedist('generalized pareto','k',1/alpha,'sigma',beta/alpha,'theta',beta);
%pd.mean()
%pd.var()

%wbl
%wa=1 to wykladniczy
%uwa=linspace(0.1,4,5);
uwa=logspace(-1,0.8,4)
uwa=[0.2,1]
lambdar=logspace(-7,-5,2);
lambdar=[3.18e-7];


files={'sieci/slacomp-germany.mat','sieci/slacomp-us.mat'}
files={'sieci/slacomp-germany.mat','sieci/slacomp-us.mat'}
%-u 2 tyl;ko waibull
%-d 
ddist=2:4
ddist=[3]

%% generacja przypadków symulacyjnych do sprawdzania subaddytywnoœci
fid=fopen('ISJ/subadd2.txt','w');
xfid=fopen('ISJ/params2.cfg','w');
for i1=1:length(dpa)
    for i2=1:length(dpb)
        for i3=1:length(uwa)
            for i4=1:length(lambdar)
                for i5=1:length(files)
                    for i6=1:length(ddist)
                        uuido=java.util.UUID.randomUUID();
                        uuids=char(uuido.toString());
                        fprintf(fid,'%s, %f,%f,%f,%f,%s,%d\n',uuids,dpa(i1), dpb(i2),uwa(i3),lambdar(i4),files{i5},ddist(i6));
                        
                        fprintf(xfid,'-i %s.js -o %s.txt -n 100000 -p 5 -u 2 -d %d -h 1 \n',uuids,uuids,ddist(i6));%FixedRestartCost
                        name = fullfile('ISJ','subadd2',[uuids,'.js']);
                        
                        Slacomp2JasonNoRouterF(files{i5},lambdar(i4),dpa(i1), dpb(i2),uwa(i3),name)

                    end
                end
            end
        end
    end
end

%
fclose(fid);
fclose(xfid);