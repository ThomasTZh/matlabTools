function output = lr4mExtractChannel(input, dimension, index)
%lr4mExtractChannel - Extract one channel along an arbitrary array axis
%   OUTPUT = lr4mExtractChannel(INPUT,DIMENSION,INDEX) selects INDEX on
%   DIMENSION while retaining all other dimensions and singleton axes.

subscripts = repmat({':'}, 1, ndims(input));
subscripts{dimension} = index;
output = input(subscripts{:});
end
