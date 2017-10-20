 %y,slacomp,slacompb,cap,demand,noOfNodes
 clear
 slacomp{1}=[1,8,4,7,3];
 slacompb{1}=[1,5,2,6,3];
 noOfNodes=4;
 cap=[10,10,10,10];
 demand=[9];
 
 
 slacomp=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp,'UniformOutput', false);
 slacompb=cellfun(@(arg) linksOnly(arg,noOfNodes),slacompb,'UniformOutput', false);
 

 
 y=[...        %5,6,7,8
     1,0,0,0,0, 0,0,1,0;... %0, zapas
     2,0,0,0,0, 0,0,0,0;... %0 ok
     3,0,0,0,0, 0,0,1,0;... %0 zapas
     8,0,0,0,0, 0,1,1,0;... %1 awaria
     12,0,0,0,0, 0,0,1,0;...%0 zapas dziala
     15,0,0,0,0, 0,0,0,0;... %0 ok
     ];
 
 
[idx,C]=SBPPidx(y,slacomp, slacompb,cap',demand,noOfNodes) 