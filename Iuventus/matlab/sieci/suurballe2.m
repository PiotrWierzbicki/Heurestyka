function [ primary, backup ] = suurballe2( A, linksnumerical, src,dst )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

links = zeros( size(A) );
for i = 1 : length( linksnumerical )
    links( linksnumerical( i, 1 ), linksnumerical( i, 2 ) ) = i;
    links( linksnumerical( i, 2 ), linksnumerical( i, 1 ) ) = i;
end
n=size(linksnumerical,1);
Alist=[linksnumerical,ones(n,4)];
Alist(:,4)=inf(n,1);
load=zeros(n,1)+1;
%[ cost, path ] = dijkstraST(  Alist, links, load, src, dst, 0 )
[ cost, path, backup ] = suurballe( Alist, links, load, src, dst, 0 );

    function y=p2nodes(p)

        y=zeros(length(p)+1,1);
        y(1)=src;
        curHop=src;

        for i=1:length(p)
            l=linksnumerical(p(i),:);
            if l(1)==curHop;
                curHop=l(2);
            else
                curHop=l(1);
            end
            y(i+1)=curHop;
        end
    end
primary=p2nodes(path)';
backup=p2nodes(backup)';
end

