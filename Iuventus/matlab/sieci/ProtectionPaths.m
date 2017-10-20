function [ paths ] = ProtectionPaths( A,r ,farthestPreviousHop, farthestNextHop)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

n=length(r);
paths=cell(n-1,1);
noOfNodes=size(A,1);

for i=1:n-1
    Ap=A;
    %remove link
    Ap(r(i),r(i+1))=0;
    Ap(r(i+1),r(i))=0;
    %compute alternative
    paths{i}=dijkstra(noOfNodes,1./Ap,r(1),r(end), farthestPreviousHop, farthestNextHop);

end

end

