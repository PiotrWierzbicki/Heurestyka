function [ output_args ] = paramFromEnv( name,default )
%UNTITLED3 parametr ze srodowiska

e=getenv(name);
if isempty(e)
    output_args = default;
else
    if isa(default,'numeric')
        output_args=str2double(e);
    else
        output_args=e;
    end
end
end

