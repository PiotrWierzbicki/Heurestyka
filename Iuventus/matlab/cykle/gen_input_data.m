%% GENERAL INFORMATION
% Input data generator for the optimization module using the Dijkstra's
% shortest path algorithm to compute the (near) optimal routing scheme.
%
% Author: Piotr Jaglarz (pjaglarz@student.agh.edu.pl)
% Date: 04.2014

%% INPUT DATA FOR THE OPTIMIZATION MODULE

% Clear the environment

	close all;
	clear all;
	clc;

% Network topology (undirected graph)

    % XML file containing the topology data (compatible with SNDlib format)

    filename = 'nobel-germany.xml';

    tree = xmlread( filename );

    % Read names of all the network nodes from the XML file
    % Array of structures, each containing the following fields:
    %	xml_network_nodes(n).name - descriptive node name
    %	xml_network_nodes(n).x - x coordinate
    %	xml_network_nodes(n).y - y coordinate

    xml_network_nodes = xml_get_network_nodes( tree );
    nodes = cell( [ xml_network_nodes.name ] );

    % Read names of all the network links from the XML file
    % Array of structures, each containing the following fields:
    %	xml_network_links(n).name - descriptive link name
    %	xml_network_links(n).src - source node descriptive name
    %	xml_network_links(n).dst - destination node descriptive name
    %	xml_network_links(n).throughput - link throughput
    %	xml_network_links(n).weight - link weight (for example: cost, distance)

    xml_network_links = xml_get_network_links( tree );

    % Read names of all the network demands from the XML file
    % Array of structures, each containing the following fields:
    %	xml_network_demands(n).name - descriptive demand name
    %	xml_network_demands(n).src - source node descriptive name
    %	xml_network_demands(n).dst - destination node descriptive name
    %	xml_network_demands(n).value - demand traffic value

    xml_network_demands = xml_get_network_demands( tree );

    % Translate the data into the appropriate structures
    % Links (arcs) - array of structures, each containing the following fields:
    %	A(n,1) - src - source node index
    %	A(n,2) - dst - destination node index
    %	A(n,3) - weight - link weight (for example: cost, distance)
    %   A(n,4) - throughput - link throughput
    %   A(n,5) - distance - link distance
    %	A(n,6) - status - the current status of the link:
    %		0: down
    %		1: up
    %		2: sleeping (? - may be useful when substituting a node..)

    A = zeros( length( xml_network_links ), 6 );
    
    for i = 1 : length( xml_network_links )
        % XML file from SNDlib contains only links in one direction!

        for j = 1 : length( xml_network_nodes )
            if strcmp( xml_network_nodes( j ).name, xml_network_links( i ).src ) == 1
                A( i, 1 ) = j;
                dx = str2double( xml_network_nodes( j ).x );
                dy = str2double( xml_network_nodes( j ).y );

                break;
            end
        end

        for j = 1 : length( xml_network_nodes )
            if strcmp( xml_network_nodes( j ).name, xml_network_links( i ).dst ) == 1
                A( i, 2 ) = j;
                dx = str2double( xml_network_nodes( j ).x ) - dx;
                dy = str2double( xml_network_nodes( j ).y ) - dy;

                break;
            end
        end

        A( i, 3 ) = str2double( xml_network_links( i ).weight );
        % A( i, 4 ) = str2double( xml_network_links( i ).throughput );
        A( i, 4 ) = Inf;
        A( i, 5 ) = round( sqrt( dx^2 + dy^2 ) * 111 );
        A( i, 6 ) = 1;

    end

    % Traffic demands - array of structures, each containing the following fields:
    %	d(n,1) - src - source node index
    %	d(n,2) - dst - destination node index
    %	d(n,3) - value - size of the traffic demand

    %% step: 1 - unidirectional (single) demand / 2 - directional demands
    step = 1;
    counter = 1;
    d = zeros( step * length( xml_network_demands ), 3 );
    for i = 1 : length( xml_network_demands )

        for j = 1 : length( xml_network_nodes )
            if strcmp( xml_network_nodes( j ).name, xml_network_demands( i ).src ) == 1
                d( counter, 1 ) = j;

                break;
            end
        end

        for j = 1 : length( xml_network_nodes )
            if strcmp( xml_network_nodes( j ).name, xml_network_demands( i ).dst ) == 1
                d( counter, 2 )= j;

                break;
            end
        end

        d( counter, 3 ) = str2double( xml_network_demands( i ).value );

        if step == 2
            % The same for the opposite direction
            d( counter + 1, 2 ) = d( counter, 1 );
            d( counter + 1, 1 ) = d( counter, 2 );
            d( counter + 1, 3 ) = d( counter, 3 );
        end

        counter = counter + step;
    end
    d = unique( d, 'rows' );
    
   
%     % Optional manual demands
%     d = [ 2 7 200; 7 2 200; 5 7 300; 7 5 300; 2 6 250; 6 2 250; 4 8 80; 8 4 80; 1 3 350; 
%         3 1 350; 6 7 150; 7 6 150; 4 3 90; 3 4 90; 5 1 100; 1 5 100; 12 3 200; 3 12 200; 
%         1 8 150; 8 1 150; 10 9 250; 9 10 250; 8 6 200; 6 8 200; 6 10 300; 10 6 300 ];


    %% Remove repeated demands if SNDlib file contains demands in two directions
    
    remove_repeated_demands = true;
    if remove_repeated_demands == 1
                
        for i = 1 : length( d )
            [ ~, Locb] = ismember( [ d( i, 2) d( i, 1 ) d( i, 3 ) ], d, 'rows' );
            if Locb > 0
                d( Locb, : ) = 0;
            end
        end
        
        d = setdiff( d, [ 0 0 0 ], 'rows' );
        
        % optional
        % d( :, 3 ) = 2 * d( :, 3 );
    end
    
    
    % Convert A matrix to links adjacency matrix
    links = zeros( length( nodes ) );
    for i = 1 : length( A )
        links( A( i, 1 ), A( i, 2 ) ) = i;
        links( A( i, 2 ), A( i, 1 ) ) = i;
    end
    

    % Link cost function lookup table (one row per link)
    %	Cx - array of arguments (link load)
    %	Cy - array of values (link cost for the corresponding load)
    % Assumption: the first column of Cx always contains zeros.

    step = 10;
    Max = 150000;
    Cx = zeros( length( A ), 1 + Max / step );
    
    for j = 1 : length( A )
       Cx( j, : ) = 0 : step : Max;
    end
	
	Cy = sqrt( Cx );
	

%% SAVE ALL THE VARIABLES INTO A .mat FILE

    save( 'input', 'A', 'd', 'nodes', 'links', 'Cx', 'Cy', 'filename' );
