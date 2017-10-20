function [ Q ] = kronsum( Q1,Q2 )
%KRONSUM suma kronecker
%   Detailed explanation goes here

Q=kron(Q1,speye(size(Q2)))+kron(speye(size(Q1)),Q2);
end

