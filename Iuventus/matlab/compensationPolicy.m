function [ penalty ] = compensationPolicy( dt,tmax, t, th )
%
if strcmp(t,'cptime')
    penalty=sum(dt);
elseif strcmp(t,'cpfail')
    penalty=sum(dt>0);
elseif strcmp(t,'cpth')
    penalty=sum(dt>th);
end
%penalty=sum(dt)/tmax;
%penalty=length(dt)/tmax;
%penalty=sum(dt(dt>2*std(dt)))/t(end);
%penalty=sum(dt);
end

