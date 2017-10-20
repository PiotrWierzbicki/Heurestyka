%% GENERAL INFORMATION
% Function that extracts network node names from an XML data file provided
% by the SNDlib project (http://sndlib.zib.de).
%
% Author: Andrzej Kamisinski (andrzej.kamisinski@ktd.krakow.pl)
% Date: 12.2013

%%

function result = xml_get_network_nodes( root )

result = struct( ...
	'name', {}, ...
    'x', {}, ...
    'y', {} ...
);

if root.hasChildNodes
	% Enter the 'network' level
	
	child_nodes = root.getChildNodes();
	
	for z = 0 : ( child_nodes.getLength() - 1 )
		if strcmp( child_nodes.item( z ).getNodeName(), 'network' ) == 1
			xml_level_network = child_nodes.item( z );
			
			break;
		end
	end
	
	% Enter the 'networkStructure' level
	
	child_nodes = xml_level_network.getChildNodes();
	
	for z = 0 : ( child_nodes.getLength() - 1 )
		if strcmp( child_nodes.item( z ).getNodeName(), 'networkStructure' ) == 1
			xml_level_network_structure = child_nodes.item( z );
			
			break;
		end
	end
	
	% Enter the 'nodes' level
	
	child_nodes = xml_level_network_structure.getChildNodes();
	
	for z = 0 : ( child_nodes.getLength() - 1 )
		if strcmp( child_nodes.item( z ).getNodeName(), 'nodes' ) == 1
			xml_level_nodes = child_nodes.item( z );
			
			break;
		end
	end
	
	% Get names of all the network nodes
	
	child_nodes = xml_level_nodes.getChildNodes();
	struct_counter = 1;
	
	for i = 0 : ( child_nodes.getLength() - 1 )
		if strcmp( child_nodes.item( i ).getNodeName(), 'node' ) == 0
			continue;
		end
		
		result( struct_counter ).name = child_nodes.item( i ).getAttribute( 'id' );
        
        % Node parameters
		
		sub_child_nodes = child_nodes.item( i ).getChildNodes();
        sub_child_nodes = sub_child_nodes.item( 1 ).getChildNodes();
		
        for j = 0 : ( sub_child_nodes.getLength() - 1 )
			if strcmp( sub_child_nodes.item( j ).getNodeName(), '#text' ) == 1
				continue;
			end
			
			sub_element_name = char( sub_child_nodes.item( j ).getNodeName() );
			
			switch sub_element_name
				case 'x'
					result( struct_counter ).x = sub_child_nodes.item( j ).getFirstChild().getNodeValue();
				case 'y'
					result( struct_counter ).y = sub_child_nodes.item( j ).getFirstChild().getNodeValue();
			end
        end
        
		struct_counter = struct_counter + 1;
	end
end