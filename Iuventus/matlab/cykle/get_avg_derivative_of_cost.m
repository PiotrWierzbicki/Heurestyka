%% GENERAL INFORMATION
% This function returns the average 'derivative' of cost in a given point (on the grounds of a lookup table).
%
% Author: Piotr Jaglarz (pjaglarz@student.agh.edu.pl)
% Date: 04.2014


function dc = get_avg_derivative_of_cost( Cx_row, Cy_row, load, k )

N = 15;
index = N - k + 1;

if index <= 1
    error( 'Index of iterations is too small ...' );
end

dc = 0;

if load > Cx_row( index )       
	
	for m = index + 1 : length( Cx_row )
		if Cx_row( m ) == load
			dc_1 = ( Cy_row( 1, m ) - Cy_row( 1, m - 1 ) ) / ( Cx_row( 1, m ) - Cx_row( 1, m - 1 ) );
			dc_2 = ( Cy_row( 1, m + 1 ) - Cy_row( 1, m ) ) / ( Cx_row( 1, m + 1 ) - Cx_row( 1, m ) );
			
			dc = ( dc_1 + dc_2 ) / 2;
			
			break;
		elseif Cx_row( 1, m ) > load
			dc = ( Cy_row( 1, m ) - Cy_row( 1, m - 1 ) ) / ( Cx_row( 1, m ) - Cx_row( 1, m - 1 ) );

			break;
		end	
	end
	
else
	dc = Cy_row( index ) / Cx_row( index );
end