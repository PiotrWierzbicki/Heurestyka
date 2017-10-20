function [R] = sbpp_w(states,times,primaries,secondaries,demand,limits, Policy,thr)
    sbppcost=sbpp(states,times,primaries,secondaries,demand,limits, Policy);
    if(strcmp(Policy,'linear'))
        R=sbppcost*demand';
    else
        R = sbppcost*demand'/thr;
    end
end
