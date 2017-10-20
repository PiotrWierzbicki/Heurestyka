%% 1
clear
close all

pliki={...
'WSa0.8GER.mat'...
'WSa1.0GER.mat'...
'WSa1.2GER.mat'...
'WSa1.4GER.mat'...
'WSa1.6GER.mat'...
'WSa1.8GER.mat'...
'WSa2.0GER.mat'...
'WSa2.3GER.mat'...
'WSa2.4GER.mat'...
'WSa2.8GER.mat'...
}

a=[];
metryka=[];
arg=0.95;

for i=1:length(pliki)
    disp(pliki{i});
    disp(i);
    load(['wyniki/',pliki{i}]);
    subanaliza3
end
plot(a, metryka)

data=[a;metryka]';
save -ASCII pt/g.t.np.txt data

%% 2
clear
close all

pliki={...
'WSa0.8US.mat'...
'WSa1.0US.mat'...
'WSa1.2US.mat'...
'WSa1.4US.mat'...
'WSa1.6US.mat'...
'WSa1.8US.mat'...
'WSa2.0US.mat'...
'WSa2.3US.mat'...
'WSa2.4US.mat'...
'WSa2.8US.mat'...
}

a=[];
metryka=[];
arg=0.95;

for i=1:length(pliki)
    disp(pliki{i});
    disp(i);
    load(['wyniki/',pliki{i}]);
    subanaliza3
end
plot(a, metryka)

data=[a;metryka]';
save -ASCII pt/u.t.np.txt data

%% 3
clear
close all

pliki={...
'P_WSa0.8GER.mat'...
'P_WSa1.0GER.mat'...
'P_WSa1.2GER.mat'...
'P_WSa1.4GER.mat'...
'P_WSa1.6GER.mat'...
'P_WSa1.8GER.mat'...
'P_WSa2.0GER.mat'...
'P_WSa2.3GER.mat'...
'P_WSa2.4GER.mat'...
'P_WSa2.8GER.mat'...
}

a=[];
metryka=[];
arg=0.95;

for i=1:length(pliki)
    disp(pliki{i});
    disp(i);
    load(['wyniki/',pliki{i}]);
    subanaliza3
end
plot(a, metryka)

data=[a;metryka]';
save -ASCII pt/g.t.p.txt data
%% 5
clear
close all

pliki={...
'P_WSa0.8US.mat'...
'P_WSa1.0US.mat'...
'P_WSa1.2US.mat'...
'P_WSa1.4US.mat'...
'P_WSa1.6US.mat'...
'P_WSa1.8US.mat'...
'P_WSa2.0US.mat'...
'P_WSa2.3US.mat'...
'P_WSa2.4US.mat'...
'P_WSa2.8US.mat'...
}

a=[];
metryka=[];
arg=0.95;

for i=1:length(pliki)
    disp(pliki{i});
    disp(i);
    load(['wyniki/',pliki{i}]);
    subanaliza3
end
plot(a, metryka)

data=[a;metryka]';
save -ASCII pt/u.t.p.txt data

%%faile
%%.......................................................................

%% 6
clear
close all

pliki={...
'WSa0.8GER.fail.mat'...
'WSa1.0GER.fail.mat'...
'WSa1.2GER.fail.mat'...
'WSa1.4GER.fail.mat'...
'WSa1.8GER.fail.mat'...
'WSa2.0GER.fail.mat'...
'WSa2.3GER.fail.mat'...
'WSa2.8GER.fail.mat'...
}

a=[];
metryka=[];
arg=0.95;

for i=1:length(pliki)
    disp(pliki{i});
    disp(i);
    load(['wyniki/',pliki{i}]);
    subanaliza3
end
plot(a, metryka)

data=[a;metryka]';
save -ASCII pt/g.f.np.txt data

%% 7 faile US
clear
close all

pliki={...
'WSa0.8US.fail.mat'...
'WSa1.0US.fail.mat'...
'WSa1.2US.fail.mat'...
'WSa1.4US.fail.mat'...
'WSa1.8US.fail.mat'...
'WSa2.0US.fail.mat'...
'WSa2.3US.fail.mat'...
'WSa2.8US.fail.mat'...
}

a=[];
metryka=[];
arg=0.95;

for i=1:length(pliki)
    disp(pliki{i});
    disp(i);
    load(['wyniki/',pliki{i}]);
    subanaliza3
end
plot(a, metryka)

data=[a;metryka]';
save -ASCII pt/u.f.np.txt data

%% protekcja faile US
clear
close all

pliki={...
'P_WSa0.8US.fail.mat'...
'P_WSa1.0US.fail.mat'...
'P_WSa1.2US.fail.mat'...
'P_WSa1.4US.fail.mat'...
'P_WSa1.8US.fail.mat'...
'P_WSa2.0US.fail.mat'...
'P_WSa2.3US.fail.mat'...
'P_WSa2.8US.fail.mat'...
}

a=[];
metryka=[];
arg=0.95;

for i=1:length(pliki)
    disp(pliki{i});
    disp(i);
    load(['wyniki/',pliki{i}]);
    subanaliza3
end
plot(a, metryka)

data=[a;metryka]';
save -ASCII pt/u.f.p.txt data

%% protekcja faile GER
clear
close all

pliki={...
'P_WSa0.8GER.fail.mat'...
'P_WSa1.0GER.fail.mat'...
'P_WSa1.2GER.fail.mat'...
'P_WSa1.4GER.fail.mat'...
'P_WSa1.8GER.fail.mat'...
'P_WSa2.0GER.fail.mat'...
'P_WSa2.3GER.fail.mat'...
'P_WSa2.8GER.fail.mat'...
}

a=[];
metryka=[];
arg=0.95;

for i=1:length(pliki)
    disp(pliki{i});
    disp(i);
    load(['wyniki/',pliki{i}]);
    subanaliza3
end
plot(a, metryka)

data=[a;metryka]';
save -ASCII pt/g.f.p.txt data

%% pol th2

clear
close all

pliki={...
'P_WSa0.8GER.th2.mat'...
'P_WSa1.2GER.th2.mat'...
'P_WSa2.3GER.th2.mat'...
}

a=[];
metryka=[];
arg=0.95;

for i=1:length(pliki)
    disp(pliki{i});
    disp(i);
    load(['wyniki/',pliki{i}]);
    subanaliza3
end
plot(a, metryka)

data=[a;metryka]';
save -ASCII pt/g.th.p.txt data

%% pol th2 bez protekcji

clear
close all

pliki={...
'WSa0.8GER.th2.mat'...
'WSa1.2GER.th2.mat'...
'WSa2.3GER.th2.mat'...
}

a=[];
metryka=[];
arg=0.95;

for i=1:length(pliki)
    disp(pliki{i});
    disp(i);
    load(['wyniki/',pliki{i}]);
    subanaliza3
end
plot(a, metryka)

data=[a;metryka]';
save -ASCII pt/g.th.np.txt data

%% pol th2 US

clear
close all

pliki={...
'P_WSa0.8US.th2.mat'...
'P_WSa1.2US.th2.mat'...
'P_WSa2.3US.th2.mat'...
}

a=[];
metryka=[];
arg=0.95;

for i=1:length(pliki)
    disp(pliki{i});
    disp(i);
    load(['wyniki/',pliki{i}]);
    subanaliza3
end
plot(a, metryka)

data=[a;metryka]';
save -ASCII pt/u.th.p.txt data

%% pol th2 US bez protekcji

clear
close all

pliki={...
'WSa0.8US.th2.mat'...
'WSa1.2US.th2.mat'...
'WSa2.3US.th2.mat'...
}

a=[];
metryka=[];
arg=0.95;

for i=1:length(pliki)
    disp(pliki{i});
    disp(i);
    load(['wyniki/',pliki{i}]);
    subanaliza3
end
plot(a, metryka)

data=[a;metryka]';
save -ASCII pt/u.th.np.txt data