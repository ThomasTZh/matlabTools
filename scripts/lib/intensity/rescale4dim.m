function data4out = rescale4dim(data2scale, range4out, dim4scale)
%RESCALE4DIM Rescale multidimensional data along specific dimensions.
%
% Description:
%   data4out = rescale4multiDim(data2scale) rescales the entire array
%   data2scale to the default range [0, 1].
%   data4out = rescale4multiDim(data2scale, range4out) rescales the array
%   to the specified range4out [minVal, maxVal].
%   data4out = rescale4multiDim(data2scale, range4out, dim4scale) rescales
%   data independently across the dimensions specified in dim4scale.
%   For example, if dim4scale is 3 for a 3D array, each 2D slice along
%   the 3rd dimension is rescaled independently.
%
% Syntax:
%   data4out = rescale4dim(data2scale)
%   data4out = rescale4dim(data2scale, range4out)
%   data4out = rescale4dim(data2scale, range4out, dim4scale)
%
% Input Arguments:
%   data2scale - Multidimensional numeric array to be rescaled.
%   range4out  - 1x2 numeric array specifying [min, max] of output.
%                Default is [0, 1]. Empty [] also uses default.
%   dim4scale  - Scalar or vector of dimensions. The rescaling operation
%                treats these dimensions as independent batches.
%
% Output Arguments:
%   data4out   - Rescaled data array of the same size as data2scale.
%
% Examples:
%   % Rescale each slice of a 3D volume independently to [-1, 1]:
%   vol2scale = rand(100, 100, 20);
%   vol4out = rescale4dim(vol2scale, [-1, 1], 3);

    % Validate input count
    narginchk(1, 3);
    
    % Default output range
    if nargin < 2 || isempty(range4out)
        range4out = [0, 1];
    end
    
    % Default dimension to scale (empty means scale globally)
    if nargin < 3
        dim4scale = [];
    end
    
    % Validate input attributes
    validateattributes(data2scale, {'numeric'}, {'real'}, ...
        'rescale4dim', 'data2scale', 1);
    validateattributes(range4out, {'numeric'}, ...
        {'vector', 'numel', 2, 'increasing', 'real', 'finite'}, ...
        'rescale4dim', 'range4out', 2);
    validateattributes(dim4scale, {'numeric'}, ...
        {'vector', 'integer', 'positive'}, ...
        'rescale4dim', 'dim4scale', 3);
        
    % Convert integer types to double for precision during division
    if ~isfloat(data2scale)
        data2scale = double(data2scale);
    end
    
    % Determine dimensions to operate over
    max4dim = max([ndims(data2scale), dim4scale]);
    dims4all = 1:max4dim;
    dims2op = setdiff(dims4all, dim4scale);
    
    % If dims2op is empty, each element is scaled independently
    if isempty(dims2op)
        data4out = zeros(size(data2scale), 'like', data2scale) + ...
            range4out(1);
        return;
    end
    
    % Compute min and max over the specified operating dimensions
    min4data = min(data2scale, [], dims2op, 'omitnan');
    max4data = max(data2scale, [], dims2op, 'omitnan');
    
    % Calculate the data range and prevent division by zero
    range4data = max4data - min4data;
    range4data(range4data == 0) = 1;
    
    % Normalize data to [0, 1] using implicit expansion
    norm4data = (data2scale - min4data) ./ range4data;
    
    % Scale to the target output range
    diff4range = range4out(2) - range4out(1);
    data4out = norm4data .* diff4range + range4out(1);
end