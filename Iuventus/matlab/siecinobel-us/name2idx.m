function [ idx ] = name2idx( name, ids )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

booleanIndex = strcmp(name, ids);
idx = find(booleanIndex);
end

