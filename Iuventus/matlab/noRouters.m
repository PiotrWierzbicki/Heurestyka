function ret=noRouters(p,noOfNodes)
    p(p<=noOfNodes)=[];
    ret = p-noOfNodes;
end

