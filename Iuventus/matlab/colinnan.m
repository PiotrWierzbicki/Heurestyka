function [ o ] = colinnan( col, ncol,  maxcol )
%ustawia kolumne w macierzy nan
assert(ncol <= maxcol)

o=nan(size(col,1),maxcol);
o(:,ncol)=col;
end

