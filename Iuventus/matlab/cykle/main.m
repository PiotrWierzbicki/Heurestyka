%% GENERAL INFORMATION
% Optimization module using the Dijkstra's shortest path algorithm
% to compute the (near) optimal routing scheme.
%
% Author: Piotr Jaglarz (pjaglarz@student.agh.edu.pl)
% Date: 04.2014

%% INPUT

% Clear the environment

	close all;
    clear all;
	clc;

 for protection_on = 0 : 1
% Read the complete environment snapshot from a .mat file

    if protection_on == 0
        fprintf( 'Rozpoczynam standardowa optymalizacje...\n\n' );
    else
        fprintf( 'Rozpoczynam optymalizacje dla protekcji...\n\n' );
    end
    
	clearvars -except protection_on;
    load( 'input' );

%% MODIFIED YAGED'S ALGORITHM
% (Pioro --> Algorithm 5.12 with the proposed modification 5.6.2)

    k = 0;                                      % Iteration counter
	F = Inf;                                    % Global cost
	F_new = Inf;                                % Global cost -> new value
	Pd = zeros( length( d ), length( A ) );     % Shortest paths for the corresponding traffic demands
    backup_paths = zeros( length( d ), length( A ) );
    
    while ( 1 )
        
		% For each traffic demand, find the shortest path and increase the load
		% of the corresponding links
    	y = zeros( length( A ), 1 );                        % Link loads
		
		for i = 1 : length( d )
            if protection_on == 0
                [ cost, path ] = dijkstra( A, links, y, d( i, 1 ), d( i, 2 ), d( i, 3 ) );
            else
                [ cost, path, backup ] = suurballe( A, links, y, d( i, 1 ), d( i, 2 ), d( i, 3 ) );
            end

			if cost == Inf
				warning( 'There is no path between nodes %d and %d.\n', d( i, 1 ), d( i, 2 ) );
            else
                Pd( i, : ) = zeros( 1, length( A ) );                   % Remove the previous shortest path entry
                for m = 1 : length( path )
                    y( path( m ) ) = y( path( m ) ) + d( i, 3 );        % Increase the link load
                    Pd( i, m ) = path( m );                 			% Update the shortest path for the demand (link predecessor sequence)
                end
                
                if protection_on == 1
                    backup_paths( i, : ) = zeros( 1, length( A ) );
                    for m = 1 : length( backup )
                        y( backup( m ) ) = y( backup( m ) ) + d( i, 3 );    % optional - backup path cost
                        backup_paths( i, m ) = backup( m );
                    end
                end
			end
		end
		
		% Compute the global cost of the network
		
		F = F_new;
		F_new = global_cost( Cx, Cy, y );
        disp( F_new );
        y_sum = sum( y > 0 );
        disp( y_sum );
        
        % Determine whether another iteration is needed
		
		if F_new == F
			
            if protection_on == 0
                uniq = unique( Pd );
                sleep = 1 : length( A );
                sleep = setdiff( sleep, uniq );
            end
            
            % STOP
			break;
		end
        
		% For each link, compute the derivatives (link unit costs)

		for i = 1 : length( A )
			A( i, 3 ) = get_avg_derivative_of_cost( Cx( i, : ), Cy( i, : ), y( i ), k );
		end

		k = k + 1;
    end
    
	fprintf( 'k = %d\n\n', k );

    
%% SAVE THE SELECTED VARIABLES INTO A .mat FILE

    if protection_on == 0
        save( 'output', 'A', 'd', 'nodes', 'links', 'Cx', 'Cy', 'y', 'Pd', 'sleep' );
    else
        save( 'output_prot', 'A', 'd', 'nodes', 'links', 'Cx', 'Cy', 'y', 'Pd', 'backup_paths' );
    end
    
 end