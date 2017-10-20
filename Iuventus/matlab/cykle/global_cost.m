%% GENERAL INFORMATION
% This function returns the global cost value for the network.
% 
% Input:
%	y - vector of link loads
%
% Author: Piotr Jaglarz (pjaglarz@student.agh.edu.pl)
% Date: 04.2014

function gc = global_cost( Cx, Cy, y )

gc = 0;

for i = 1 : length( y )
	gc = gc + link_cost( Cx( i, : ), Cy( i, : ), y( i ) );
end