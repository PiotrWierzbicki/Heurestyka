function [ slacov ] = slacov( numer, numer2,paths,moments,tmax,compensation,varargin )
%funckja liczy kowariancje dla pary sla-a:

pp=paths{numer};
pp2=paths{numer2};

wspolne = intersect(pp, pp2);


if ~isempty(wspolne)
    msla = moments(wspolne);

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

    workingStates = 1;
    failedStates = 2:d;

%     D=diag(Q);
%     Pemb = speye(size(Q))-spdiags(1./D,0,d,d)*Q;
%     pi=stableMarkovChaindistribution(Pemb);


    % Prwdopobienstwo rozkladu przy wejsciach do grupy stanów
    % zakaldam, ze stan jest liczony przed przeskokiem
%     Pingrupa= pi(failedStates)/sum(pi(failedStates));
    [ Pingrupa] = groupenterprob( Q,failedStates,workingStates );

    T=Q(failedStates,failedStates);
    r=Q(failedStates,workingStates);
    [ m1,vm ] = comppol( T,r,Pingrupa,compensation,varargin );
%     switch compensation
%         case 'avail'
%             m1=full(Pingrupa*(sum(T^2\r,2)));
%             m2=full(Pingrupa*(-2*sum(T^3\r,2)));
%         case 'snowball'
%             m1=full(Pingrupa*(-2*sum(T^3\r,2)));
%             m2=full(Pingrupa*(-24*sum(T^5\r,2)));
%         case 'cont'
%             m1=1;
%             m2=1;
%     end
% 
% 
%     vm=m2-m1^2;
%     mu1 = sum(arrayfun(@(x) x.a ,msla)); % sumujemy lambdy
%     sigma= sqrt(mu1); %variancja
%     slacov=tmax/mu1*vm + m1^2*(sigma^2*tmax/mu1^3);
    en = sum(arrayfun(@(x) 1./x.a ,msla));
    vn=sum(arrayfun(@(x) x.sa^2./x.a^3 ,msla));
    slacov=tmax*(en*vm+m1^2*vn);
else
    slacov=0;
end

end

