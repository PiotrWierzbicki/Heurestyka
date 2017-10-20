%% GENERAL INFORMATION
% Function that extracts network demands from an XML data file provided
% by the SNDlib project (http://sndlib.zib.de).
%
% Author: Piotr Jaglarz (pjaglarz@student.agh.edu.pl)
% Date: 04.2014

%%

function result = xml_get_network_demands( root )

result = struct( ...
    'name', {}, ...
	'src', {}, ...
	'dst', {}, ...
    'value', {} ...
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
	
	% Enter the 'demands' level
	
	child_nodes = xml_level_network.getChildNodes();
	
	for z = 0 : ( child_nodes.getLength() - 1 )
        if strcmp( child_nodes.item( z ).getNodeName(), 'demands' ) == 1
			xml_level_demands = child_nodes.item( z );
			
			break;
        end
	end
    
	
	% Get names of all the network nodes
	
	child_nodes = xml_level_demands.getChildNodes();
	struct_counter = 1;
	
	for i = 0 : ( child_nodes.getLength() - 1 )
		if strcmp( child_nodes.item( i ).getNodeName(), 'demand' ) == 0
			continue;
		end
		
		result( struct_counter ).name = child_nodes.item( i ).getAttribute( 'id' );
        
        % Demand parameters
		
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
                case 'demandValue'
					result( struct_counter ).value = sub_child_nodes.item( j ).getFirstChild().getNodeValue();
			end
        end
        
		struct_counter = struct_counter + 1;
	end
end