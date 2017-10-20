function [ wa,wb ] = wblfrompareto( a,b )
%UNTITLED weibula  o sredniej i wariancji jak pareto
    [pm,pv] = gpstat(1/a,b/a,b);

tmp=gprnd(1/a,b/a,b,10000,1);
w=wblfit(tmp);


    function y=f(x)
        y=pm^2.*(gamma(1+2./x)-gamma(1+1./x).^2)./gamma(1+1./x)^2 -pv;
    end
wa=fzero(@f,w(2));
wb=pm./gamma(1+1./wa);
end

