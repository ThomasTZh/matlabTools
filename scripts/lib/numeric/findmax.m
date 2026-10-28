function [maxValue, index] = findmax(x, varargin)
%FINDMAX Find maximum value and specific index of occurrence.
%   [M,I] = FINDMAX(X) returns the maximum value M and the index I of the
%   maximum value in vector X. If the maximum value occurs more than once,
%   FINDMAX returns the index of the first occurrence.
%
%   [M,I] = FINDMAX(X, POS) specifies which index to return when the maximum
%   value occurs multiple times (a "plateau"). POS can be:
%       'first'  - Returns the index of the first occurrence (default).
%       'middle' - Returns the index of the middle occurrence.
%       'last'   - Returns the index of the last occurrence.
%
%   [M,I] = FINDMAX(..., NANFLAG) specifies how NaN (Not-a-Number) values 
%   are treated. NANFLAG can be:
%       'omitnan'    - Ignores NaN values (default).
%       'includenan' - Returns NaN if any value in X is NaN.
%
%   [M,I] = FINDMAX(..., DIM) operates along the dimension DIM.
%
%   Examples:
%       x = [1 2 5 5 5 2 1];
%       
%       [m, i] = findmax(x, 'first')
%       % returns m = 5, i = 3
%
%       [m, i] = findmax(x, 'middle')
%       % returns m = 5, i = 4
%
%       [m, i] = findmax(x, 'last')
%       % returns m = 5, i = 5
%
%   See also MAX, MIN, FIND.

%   program by TZ 28/11/2025

    %% 1. Parse Inputs
    p = inputParser;
    p.KeepUnmatched = false;
    
    % Validation functions
    validX = @(v) isnumeric(v) || islogical(v) || ischar(v);
    validPos = @(s) any(validatestring(lower(s), {'first', 'middle', 'last'}));
    validNan = @(s) (ischar(s) || isstring(s)) && any(validatestring(lower(s), {'omitnan', 'includenan'}));
    validDim = @(d) isnumeric(d) && isscalar(d) && (d > 0);

    % Define arguments
    addRequired(p, 'x', validX);
    addOptional(p, 'pos', 'first', validPos);
    addOptional(p, 'arg3', [], @(x) validDim(x) || validNan(x));
    addOptional(p, 'arg4', [], @(x) validDim(x) || validNan(x));

    parse(p, x, varargin{:});
    
    posSpec = lower(p.Results.pos);
    
    % Determine 'nanflag' and 'dim' from the optional arguments
    % This logic mimics MATLAB's flexible argument ordering
    nanFlagSpec = 'omitnan'; % Default
    dimSpec = [];
    
    extras = {p.Results.arg3, p.Results.arg4};
    for k = 1:2
        arg = extras{k};
        if isempty(arg)
            continue;
        elseif ischar(arg) || isstring(arg)
            nanFlagSpec = char(lower(arg));
        elseif isnumeric(arg)
            dimSpec = arg;
        end
    end
    
    % If dimension not specified, find the first non-singleton dimension
    if isempty(dimSpec)
        dimSpec = find(size(x) > 1, 1);
        if isempty(dimSpec)
            dimSpec = 1;
        end
    end

    %% 2. Calculate Maximum Value
    % We use the built-in max to get the value efficiently
    if verLessThan('matlab', '9.1') && strcmp(nanFlagSpec, 'omitnan')
        % Fallback for older MATLAB versions lacking 'omitnan' in max()
        % Create a temporary copy for calculation
        tempX = x;
        tempX(isnan(tempX)) = -inf; 
        maxValue = max(tempX, [], dimSpec);
        % If original was all NaNs, restore NaN
        allNans = all(isnan(x), dimSpec);
        maxValue(allNans) = NaN;
    else
        maxValue = max(x, [], dimSpec, nanFlagSpec);
    end

    % If user didn't request index, return early
    if nargout < 2
        return;
    end

    %% 3. Calculate Index
    % Initialize index array with same size as maxValue
    index = zeros(size(maxValue));
    
    % Determine size parameters for looping
    sz = size(x);
    
    % If x is a vector, we can simplify logic. If it's a matrix/ND-array,
    % we must iterate over the orthogonal dimensions.
    
    % Permute X so the operating dimension is first. 
    % This makes it effectively a column-wise operation.
    permOrder = [dimSpec, 1:dimSpec-1, dimSpec+1:length(sz)];
    xPerm = permute(x, permOrder);
    maxPerm = permute(maxValue, permOrder);
    
    % Reshape to 2D matrix: (Dimension of interest) x (All other dims flattened)
    origSizePerm = size(xPerm);
    numVectors = prod(origSizePerm(2:end));
    xLinear = reshape(xPerm, origSizePerm(1), numVectors);
    maxLinear = reshape(maxPerm, 1, numVectors);
    indexLinear = zeros(1, numVectors);

    % Iterate through each vector (column)
    for k = 1:numVectors
        col = xLinear(:, k);
        mVal = maxLinear(k);
        
        % Handle NaNs based on flag
        if isnan(mVal) && strcmp(nanFlagSpec, 'includenan')
             % If we are here, it means 'includenan' was on and there is a NaN.
             % Standard max returns index of first NaN.
             candidates = find(isnan(col));
        elseif isnan(mVal)
             % All values are NaN, pick first index
             candidates = 1; 
        else
             % Find all indices equal to the maximum value
             % Note: Floating point comparison is safe here because mVal 
             % is exactly one of the values in col (extracted by max).
             candidates = find(col == mVal);
        end
        
        if isempty(candidates)
            % Should not happen logically unless input is empty
            indexLinear(k) = 1; 
            continue;
        end

        % Select the specific index based on input request
        switch posSpec
            case 'first'
                indexLinear(k) = candidates(1);
            case 'last'
                indexLinear(k) = candidates(end);
            case 'middle'
                % We pick the median index. 
                % If even number of candidates, round up (ceil).
                midPtr = ceil(length(candidates) / 2);
                indexLinear(k) = candidates(midPtr);
        end
    end

    % Restore dimensions
    indexPerm = reshape(indexLinear, size(maxPerm));
    index = ipermute(indexPerm, permOrder);

end