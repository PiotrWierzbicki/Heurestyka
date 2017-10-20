function [ Pingrupa,Pinniegrupa ] = groupenterprob( Q,failedStates,workingStates )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
d=size(Q,1);
D=diag(Q);
Pemb = speye(size(Q))-spdiags(1./D,0,d,d)*Q;
pi=stableMarkovChaindistribution(Pemb);

Pingrupa= pi(failedStates)/sum(pi(failedStates));
Pinniegrupa= pi(workingStates)/sum(pi(workingStates));

%przypadek bez protekcji
% Pingrupa= Pemb(workingStates,failedStates);
% Pingrupa= Pemb(1,2:end);
% Pinniegrupa= 1;

% tmp=Pemb(workingStates,failedStates);
% tmp2=sum(tmp,2);
% tmp2(tmp2==0)=1;
% tmp=bsxfun(@ldivide,tmp2, tmp);
% 
% Pingrupa=pi(workingStates)*tmp;
% 
% tmp=Pemb(failedStates,workingStates);
% tmp2=sum(tmp,2);
% tmp2(tmp2==0)=1;
% tmp=bsxfun(@ldivide,tmp2, tmp);
% 
% Pinniegrupa=pi(failedStates)*tmp;
end

