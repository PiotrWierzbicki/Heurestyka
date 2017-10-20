function [ output_args ] = mat2strwcoma( input_args )
%UNTITLED4 mat2str wit commas

output_args = num2str(input_args);
output_args = output_args([1==1, diff(output_args)~=0] |  (output_args~=' '));
output_args = strrep(output_args,' ',',');
end

