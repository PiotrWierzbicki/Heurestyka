function [ output_args ] = linksOnly( slacomp, noOfNodes )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
slacomp(slacomp<= noOfNodes)=[];

%output_args = slacomp-noOfNodes;
output_args = slacomp;
end

