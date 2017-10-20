function [ slacov ] = protslacov( numer, numer2,paths, backupPaths,moments,tmax,compensation,varargin )
%funckja liczy kowariancje dla pary sla-a:

pp=paths{numer};
bp = backupPaths{numer};
pp2=paths{numer2};
bp2 = backupPaths{numer2};

if isempty(intersect(pp,pp2)) && isempty(intersect(bp,bp2))
    slacov=0;
    return
end
% if numel(isempty(intersect(bp,bp2)))<2
%     slacov=0;
%     return;
% end
tp=unique([pp,bp,pp2,bp2]);

msla = moments(tp);


[pi,~]=find(bsxfun(@eq,tp',pp));
[bi,~]=find(bsxfun(@eq,tp',bp));

[pi2,~]=find(bsxfun(@eq,tp',pp2));
[bi2,~]=find(bsxfun(@eq,tp',bp2));

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

workingStates2 = s.getWorkingStatesInProtection(pi2-1,bi2-1)+1;
failedStates2 = setdiff(1:d,workingStates2);

failedStates = intersect(failedStates,failedStates2);
workingStates = setdiff(1:d,failedStates);

% D=diag(Q);
% Pemb = speye(size(Q))-spdiags(1./D,0,d,d)*Q;
% pi=stableMarkovChaindistribution(Pemb);


% Prwdopobienstwo rozkladu przy wejsciach do grupy stanów
% zakaldam,  ze stan jest liczony przed przeskokiem
%Pingrupa= pi(failedStates)/sum(pi(failedStates));
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
% vm=m2-m1^2;
[ m1,vm ] = comppol( T,r,Pingrupa,compensation,varargin );
%Pinniegrupa= pi(workingStates)/sum(pi(workingStates));

mu1=Pinniegrupa*(sum(full(Q(workingStates,workingStates)^2\Q(workingStates,failedStates)),2));
mu2=Pinniegrupa*(sum(-2*full(Q(workingStates,workingStates)^3\Q(workingStates,failedStates)),2));
sigma= sqrt(mu2-mu1^2); %variancja

slacov=tmax/mu1*vm + m1^2*(sigma^2*tmax/mu1^3);


end

