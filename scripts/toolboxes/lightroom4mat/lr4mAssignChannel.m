function output = lr4mAssignChannel(output, dimension, index, values)
%lr4mAssignChannel - Assign one channel along an arbitrary array axis
%   OUTPUT = lr4mAssignChannel(OUTPUT,DIMENSION,INDEX,VALUES) writes VALUES
%   at INDEX on DIMENSION while retaining every other subscript.

subscripts = repmat({':'}, 1, ndims(output));
subscripts{dimension} = index;
output(subscripts{:}) = values;
end
