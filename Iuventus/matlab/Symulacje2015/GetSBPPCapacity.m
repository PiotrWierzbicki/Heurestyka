function [ util ] = GetSBPPCapacity( slacomp,cap,demand,noOfNodes )

util=zeros(length(slacomp), length(cap));

for i=1:length(slacomp)
    p=slacomp{i}-noOfNodes;
    util(i,p)=demand(i);
end

util=max(util);


end

