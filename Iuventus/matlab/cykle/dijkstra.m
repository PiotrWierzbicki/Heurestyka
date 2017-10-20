%% GENERAL INFORMATION
% Dijkstra's shortest path algorithm
%
% Author: Piotr Jaglarz (pjaglarz@student.agh.edu.pl)
% Date: 04.2014

function [ cost, path ] = dijkstra( A, links, load, src, dst, traffic )

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
        
        if ( dist( s ) + A( links( s, d ), 3 ) ) < dist( d ) && A( links( s, d ), 6 ) == 1
            if load( links( s, d ) ) + traffic <= A( links( s, d ), 4 )
                dist( d ) = dist( s ) + A( links( s, d ), 3 );
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
 