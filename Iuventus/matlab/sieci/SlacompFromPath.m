function [ output ] = SlacompFromPath( path, linksnumerical, nodeNumber )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


li=[];
for j=1:length(path)-1
    src=path(j);
    dst=path(j+1);
    linkid = find((linksnumerical(:,1)==src & linksnumerical(:,2)==dst)|...
            (linksnumerical(:,1)==dst & linksnumerical(:,2)==src));
    li=[li,linkid]; 
end
output=[path,li+nodeNumber];
end

