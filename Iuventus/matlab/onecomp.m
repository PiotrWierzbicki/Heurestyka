function [ tst ] = onecomp(param,tmax, id, idmax )
%Jeden komponent
t=0;

c={};
i=1;
state=0; %logika awarii

% lambdar=3.18e-7;
% alpha = 2.3;
% %alpha = 0.7;
% betam = 60;

global lambdar;
global alpha;
global betam;
global isPareto;

momenty=struct();

if strcmp(param.type,'l') 
    if param.l < 25
        lambda=lambdar;
        beta=betam;
    else
        lambda = lambdar + 9*lambdar*param.l/param.lmax;
        beta = betam + 9*betam*param.l/param.lmax;
    end
else
    lambda=lambdar;
    beta=betam;
end

momenty.a=1/lambda;
momenty.b=beta*alpha/(alpha-1);


momenty.sa = momenty.a;
if isPareto
    momenty.sb = sqrt(beta^2*alpha/((alpha-1)^2*(alpha-2))); %paretoto
else
    momenty.sb = momenty.b;
end

if nargin == 1
    tst=momenty;
    return
end


while t < tmax
    tmp=nan(1,idmax+1);
    if state
        if isPareto
            t = t + beta./(rand(1,1).^(1/alpha));
        else
            t = t + exprnd(momenty.b); %wykladniczy
        end
    else
        t=t+exprnd(1/lambda);
    end
    % zmiana wypada po roku
    if t < tmax
        state = ~state;
        tmp(1)=t;
        tmp(id+1)=state;

    else
        t=tmax;
        tmp(1)=t;
        tmp(id+1)=nan;%brak zmiany stanu
    end

    
    c{i}=tmp;
    i=i+1;
end

tst=cell2mat(c');

end

