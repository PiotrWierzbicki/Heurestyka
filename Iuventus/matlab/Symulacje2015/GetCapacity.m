function [ util ] = GetCapacity( slacomp,cap,demand,noOfNodes )

util=zeros(size(cap));

for i=1:length(slacomp)
    p=slacomp{i}-noOfNodes;
    util(p)=util(p)+demand(i);
end




end

