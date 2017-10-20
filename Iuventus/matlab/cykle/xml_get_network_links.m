%% GENERAL INFORMATION
% Function that extracts the selected network link parameters from an XML
% data file provided by the SNDlib project (http://sndlib.zib.de).
%
% Author: Andrzej Kamisinski (andrzej.kamisinski@ktd.krakow.pl)
% Date: 12.2013

%%

function result = xml_get_network_links( root )

result = struct( ...
	'name', {}, ...
	'src', {}, ...
	'dst', {}, ...
	'throughput', {}, ...
	'weight', {} ...
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
	
	% Enter the 'links' level
	
	child_nodes = xml_level_network_structure.getChildNodes();
	
	for z = 0 : ( child_nodes.getLength() - 1 )
		if strcmp( child_nodes.item( z ).getNodeName(), 'links' ) == 1
			xml_level_links = child_nodes.item( z );
			
			break;
		end
	end
	
	% Get the selected parameters of all the network links
	
	child_nodes = xml_level_links.getChildNodes();
	struct_counter = 1;
	
	for i = 0 : ( child_nodes.getLength() - 1 )
		if strcmp( child_nodes.item( i ).getNodeName(), 'link' ) == 0
			continue;
		end
		
		result( struct_counter ).name = child_nodes.item( i ).getAttribute( 'id' );
		
		% Link parameters
		
		sub_child_nodes = child_nodes.item( i ).getChildNodes();
		
		for j = 0 : ( sub_child_nodes.getLength() - 1 )
			if strcmp( sub_child_nodes.item( j ).getNodeName(), '#text' ) == 1
				continue;
			end
			
			sub_element_name = char( sub_child_nodes.item( j ).getNodeName() );
			
			switch sub_element_name
				case 'source'
					result( struct_counter ).src = sub_child_nodes.item( j ).getFirstChild().getNodeValue();
				case 'target'
					result( struct_counter ).dst = sub_child_nodes.item( j ).getFirstChild().getNodeValue();
				case 'additionalModules'
					% CONSIDERATION: Handle multiple capacity modules (?)
					
					sub_sub_child_nodes = sub_child_nodes.item( j ).getChildNodes();			% "addModule" blocks
					sub_sub_sub_child_nodes = sub_sub_child_nodes.item( 1 ).getChildNodes();	% "capacity", "cost" elements in the first addModule block
					
					for z = 0 : ( sub_sub_sub_child_nodes.getLength() - 1 )
						if strcmp( sub_sub_sub_child_nodes.item( z ).getNodeName(), 'capacity' ) == 1
							result( struct_counter ).throughput = sub_sub_sub_child_nodes.item( z ).getFirstChild().getNodeValue();
						elseif strcmp( sub_sub_sub_child_nodes.item( z ).getNodeName(), 'cost' ) == 1
							result( struct_counter ).weight = sub_sub_sub_child_nodes.item( z ).getFirstChild().getNodeValue();
						end
					end
				otherwise
					%disp( 'Unhandled link parameter - ignore.' )
			end
		end
		
		struct_counter = struct_counter + 1;
	end
end