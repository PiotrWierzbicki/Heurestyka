function [ lm,ls ] = lognfrompareto( a,b )
%UNTITLED weibula  o sredniej i wariancji jak pareto
    [pm,pv] = gpstat(1/a,b/a,b);

ls=sqrt(log(pv/pm^2+1));
lm=log(pm)-(ls^2)/2;
end

