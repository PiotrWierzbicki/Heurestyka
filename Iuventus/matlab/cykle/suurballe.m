%% GENERAL INFORMATION
% Suurballe's shortest cycle algorithm
%
% Author: Piotr Jaglarz (pjaglarz@student.agh.edu.pl)
% Date: 04.2014

function [ cost, primary, backup ] = suurballe( A, links, load, src, dst, traffic )

% STEP 1
DG = inf( length( links ) );
for i = 1 : length( A )
    DG( A( i, 1 ), A( i, 2 ) ) = A( i, 3 );
    DG( A( i, 2 ), A( i, 1 ) ) = A( i, 3 );
end

[ cost, path1, npath1, dist ] = dijkstra_md( A, DG, links, load, src, dst, traffic );
if cost == Inf
    error( 'No path1 from %d to %d - infinite cost\n', src, dst );
end


% STEP 2
for i = 2 : length( npath1 )
    links( npath1( i - 1 )  , npath1( i ) ) = -1;
end

for i = 1 : length( A )
    DG( A( i, 1 ), A( i, 2 ) ) = A( i, 3 ) - dist( A( i, 2 ) ) + dist( A( i, 1 )  );
    DG( A( i, 2 ), A( i, 1 ) ) = A( i, 3 ) - dist( A( i, 1 ) ) + dist( A( i, 2 )  );
end


% STEP 3
[ cost2, path2 ] = dijkstra_md( A, DG, links, load, src, dst, traffic );
if cost2 == Inf
    error( 'No path2 from %d to %d - infinite cost\n', src, dst );
end


% STEP 4
% check for unique
path = [ setdiff( path1, path2 ) setdiff( path2, path1 ) ];

if length( path ) == length( [ path1 path2 ] )
    
    primary = path1;
    backup = path2;
    
else
    
    links = zeros( length( links ) );
    for i = 1 : length( path )
        links( A( path( i ), 1 ), A( path( i ), 2 ) ) = path( i );
        links( A( path( i ), 2 ), A( path( i ), 1 ) ) = path( i );
    end
    
    [ cost, primary ] = dijkstra( A, links, load, src, dst, traffic );
    if cost == Inf
        error( 'There is no primary path between nodes %d and %d.\n', src, dst );
    end
    
    for i = 1 : length( primary )
        links( A( primary( i ), 1 ), A( primary( i ), 2 ) ) = 0;
        links( A( primary( i ), 2 ), A( primary( i ), 1 ) ) = 0;
    end
    
    [ cost2, backup ] = dijkstra( A, links, load, src, dst, traffic );
    if cost2 == Inf
        error( 'There is no backup path between nodes %d and %d.\n', src, dst );
    end
    
end




function [ cost, path, npath, dist ] = dijkstra_md( A, DG, links, load, src, dst, traffic )

n = length( links );       % Number of nodes in the network
visited( 1 : n ) = 0;   % Visited nodes
dist( 1 : n ) = Inf;    % It stores the shortest distance between the source node and any other node
prev( 1 : n ) = 0;      % Previous node, informs about the best previous node known to reach each network node 

dist( src ) = 0;


for j = 1 : n - 1
    
    candidate = inf( 1, n );
    for i = 1 : n
        if visited( i ) == 0
            candidate( i ) = dist( i );
        end
    end
    
    [ ~, s ] = min( candidate );
    visited( s ) = 1;
    for d = 1 : n
        if links( s, d ) == 0
            continue;
        end
        
        if ( dist( s ) + DG( s, d ) ) < dist( d ) && links( s, d ) > 0 && A( links( s, d ), 6 ) == 1
            if load( links( s, d ) ) + traffic <= A( links( s, d ), 4 )
                dist( d ) = dist( s ) + DG( s, d );
                prev( d ) = s;
            else
                warning( 'Link %d: Link capacity is full ...\n', links( s, d ) );
            end
        end
    end
    
end

cost = dist( dst );
path = 0;


if cost ~= Inf
    % Node path
    npath = dst;
    while npath( 1 ) ~= src

        if prev( npath( 1 ) ) > 0 && npath( 1 ) ~= prev( prev( npath( 1 ) ) )
            npath = [ prev( npath( 1 ) ) npath ];
        else
            error( 'Error in npath ...\n' );
        end

    end

    % Convert node path to link path
    path = zeros( 1, length( npath ) - 1 );
	for i = 1 : length( npath ) - 1
        path( i ) = links( npath( i ), npath( i + 1 ) );
	end
end
 