function [cVar] = gaussian_cVar(alpha, mu, sigma)
    e = erfinv(2*alpha-1);
    k1 = 1/(sqrt(2*pi)*exp(e^2)*(1-alpha));
    cVar = mu + k1*sigma;
end