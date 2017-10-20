function [cVar] = lognorm_cVar(alpha, mu, sigma)
    pd = makedist('Lognormal','mu',mu,'sigma',sigma);
    kw = pd.icdf(alpha);
    function y=f(x)
        y=x.*pd.pdf(x)/(1-alpha);
    end
    cVar = integral(@f,kw,inf);
end