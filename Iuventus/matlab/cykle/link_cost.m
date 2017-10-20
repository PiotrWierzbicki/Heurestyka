%% GENERAL INFORMATION
% This function returns the estimated cost of a link on the grounds of the provided parameters.
%
% Author: Piotr Jaglarz (pjaglarz@student.agh.edu.pl)
% Date: 04.2014

function c = link_cost( Cx_row, Cy_row, load )

if load == 0
	c = 0;
else
	c = Inf;
	
	for m = 1 : length( Cx_row )
		if Cx_row( m ) == load
			c = Cy_row( m );
			
			break;
		elseif Cx_row( m ) > load
			c = ( Cy_row( m - 1 ) + Cy_row( m ) ) / 2;
			
			break;
        elseif load > Cx_row( end )
            warning( 'Cx range is too small ...' );
            
            break;
		end
	end
end