clear
clc

load('GER_cptimeminRplusB_C10.mat')

CCOPT = CC;
VVOPT = VV;

load('Rand40000GER_cptime_C10.mat')

plot(CC,RR,'g.',CCOPT,VVOPT,'.',CC0,VV0,'r.')
hold on
plot(NewPop{1}.C,NewPop{1}.V,'y.','MarkerSize',30)
hold off

%%plot(minn)