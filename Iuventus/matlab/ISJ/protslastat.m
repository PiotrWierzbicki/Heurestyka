function [ esla, varsla ] = protslastat( numer,paths, backupPaths,moments,tmax,compensation,varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% numer - numer sla
% path postawowe sciezki
% backupPaths zapas
% tmax czas obserwacji
% mode typ funkcji kompensacji

pp=paths{numer};
bp = backupPaths{numer};
tp=unique([pp,bp]);

msla = moments(tp);


[pi,~]=find(bsxfun(@eq,tp',pp));
[bi,~]=find(bsxfun(@eq,tp',bp));

n=length(msla);
k=3;
if k>n
    k=n;
end
s=networkmarkov.NetworkMarkov(n,k);
lambdas=arrayfun(@(arg) 1/arg.a,msla);
mus=arrayfun(@(arg) 1/arg.b,msla);

x=s.makeQ(lambdas, mus);

d=sum(arrayfun(@(arg) nchoosek(n,arg),0:k));
Q=sparse(double(x.iidx)+1,double(x.jidx)+1,x.values,d,d);
Q=Q-diag(sum(Q,2));

workingStates = s.getWorkingStatesInProtection(pi-1,bi-1)+1;
failedStates = setdiff(1:d,workingStates);

% D=diag(Q);
% Pemb = speye(size(Q))-spdiags(1./D,0,d,d)*Q;
% pi=stableMarkovChaindistribution(Pemb);
% 

% Prwdopobienstwo rozkladu przy wejsciach do grupy stanów
% zakaldam, ze stan jest liczony przed przeskokiem
%Pingrupa= pi(failedStates)/sum(pi(failedStates));
%Pingrupa=pi(workingStates)/sum(pi(workingStates))*Pemb(workingStates,failedStates);

[ Pingrupa,Pinniegrupa ] = groupenterprob( Q,failedStates,workingStates );

T=Q(failedStates,failedStates);
r=Q(failedStates,workingStates);

% switch compensation
%     case 'avail'
%         m1=full(Pingrupa*(sum(T^2\r,2)));
%         m2=full(Pingrupa*(-2*sum(T^3\r,2)));
%     case 'snowball'
%         m1=full(Pingrupa*(-2*sum(T^3\r,2)));
%         m2=full(Pingrupa*(-24*sum(T^5\r,2)));
%     case 'cont'
%         m1=1;
%         m2=1;
% end
% 
% 
% vm=m2-m1^2;
[ m1,vm ] = comppol( T,r,Pingrupa,compensation,varargin );
%Pinniegrupa= pi(workingStates)/sum(pi(workingStates));

mu1=Pinniegrupa*(sum(full(Q(workingStates,workingStates)^2\Q(workingStates,failedStates)),2));
mu2=Pinniegrupa*(sum(-2*full(Q(workingStates,workingStates)^3\Q(workingStates,failedStates)),2));
sigma= sqrt(mu2-mu1^2); %variancja


esla = tmax/mu1*m1;
varsla=tmax/mu1*vm + m1^2*(sigma^2*tmax/mu1^3);

end

