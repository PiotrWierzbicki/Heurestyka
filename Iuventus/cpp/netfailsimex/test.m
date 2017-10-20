
js=fileread('config.js');
 % netfailsimex(json,N,udtype,ddtype,policy,scale)
 

%exit
tic
[r,lbl]= netfailsimex(js,1000,1,1,1,1);
toc
