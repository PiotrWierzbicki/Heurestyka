%% GENERAL INFORMATION
% Plot network graph
%
% Author: Piotr Jaglarz (pjaglarz@student.agh.edu.pl)
% Date: 03.2014

function plot_path( A )
 
 DG = sparse( [ A( :, 1 ); A( :, 2 ) ], [ A( :, 2 ); A( :, 1 ) ], [ A( :, 3 ); A( :, 3 ) ] );

 h = biograph( DG, [], 'ShowWeights', 'on' );
 h.view;
 
end

