function [ A ] = path2bits( path )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

A=0;

for i=1:length(path)
    A=bitset(A,path{i},'uint64');
end
end

