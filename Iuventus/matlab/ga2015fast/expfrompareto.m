function [ lambda ] = expfrompareto( a,b )
%UNTITLED weibula  o sredniej i wariancji jak pareto
    [pm] = gpstat(1/a,b/a,b);

lambda=1/pm;
end

