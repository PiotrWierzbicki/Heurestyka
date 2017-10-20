function [cVar] = gamma_cVar(alpha, ga, gb)
    pd = makedist('Gamma','a',ga,'b',gb);
    kw = pd.icdf(alpha);
    function y=f(x)
        y=x.*pd.pdf(x)/(1-alpha);
    end
    cVar = integral(@f,kw,inf);
end