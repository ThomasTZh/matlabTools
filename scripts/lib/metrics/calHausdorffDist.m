function hd = calHausdorffDist(line1, line2, varargin)
%CALHAUSDORFFDIST Calculates the Robust (Percentile) Hausdorff Distance.
%
%   Description:
%       This function computes the Hausdorff distance between two segmentation
%       lines. It measures the degree of mismatch between two sets of points
%       by finding the distance from each point in one set to the nearest
%       point in the other set.
%
%       To ensure robustness against outliers (e.g., noise pixels), this
%       implementation supports a percentile-based calculation (default 95%).
%       Instead of the maximum distance (100th percentile), it returns the
%       95th percentile of the directed distances, effectively ignoring the
%       worst 5% of outliers.
%
%   Syntax:
%       hd = calHausdorffDist(line1, line2)
%       hd = calHausdorffDist(line1, line2, xCoords)
%       hd = calHausdorffDist(line1, line2, percent)
%       hd = calHausdorffDist(line1, line2, xCoords, percent)
%       hd = calHausdorffDist(line1, line2, percent, xCoords)
%
%   Input Arguments:
%       line1   - (Numeric Array) First segmentation line. Values represent
%                 the row/column coordinate. NaN values are ignored.
%       line2   - (Numeric Array) Second segmentation line. Must be the
%                 same size as line1. NaN values are ignored.
%
%   Optional Input Arguments (order independent):
%       xCoords - (Numeric Vector) The x-coordinates corresponding to the
%                 indices of line1 and line2.
%                 Default: 1:numel(line1).
%       percent - (Scalar Double) The percentile for robust calculation.
%                 Range: [0, 100].
%                 Default: 95.
%
%   Output Arguments:
%       hd      - (Scalar Double) The calculated Hausdorff distance.
%
%   Examples:
%       % Basic usage with default 1:N x-coordinates and 95% metric
%       d = calHausdorffDist([10 10 10], [10 12 10]);
%
%       % Usage with specific x-coordinates
%       x = [0.1, 0.2, 0.3];
%       d = calHausdorffDist([10 10 10], [10 12 10], x);
%
%       % Usage with 100% (Maximum) Hausdorff Distance
%       d = calHausdorffDist([10 10 10], [10 12 10], 100);
%
%       % Mixed argument order
%       d = calHausdorffDist([10 10 10], [10 12 10], 95, x);
%
%   See also VALIDATEATTRIBUTES, PRCTILE, HYPOT.

%   Program by TZ, 02 Dec 2025.

    % ---------------------------------------------------------------------
    % 1. Input Validation and Parsing
    % ---------------------------------------------------------------------
    narginchk(2, 4);
    
    % Validate mandatory inputs
    validateattributes(line1, {'numeric'}, {'vector', 'real'}, mfilename, 'line1', 1);
    validateattributes(line2, {'numeric'}, {'vector', 'real', 'size', size(line1)}, mfilename, 'line2', 2);

    % Default values
    defaultX = 1:numel(line1);
    defaultPct = 95;

    xCoords = defaultX;
    pct = defaultPct;

    % Parse optional variable arguments
    if ~isempty(varargin)
        for k = 1:length(varargin)
            arg = varargin{k};
            
            % Distinguish inputs based on size and type
            if isscalar(arg) && isnumeric(arg)
                % It is likely the percentage
                pct = double(arg);
                validateattributes(pct, {'numeric'}, {'scalar', '>=', 0, '<=', 100}, mfilename, 'percent');
            elseif isvector(arg) && isnumeric(arg) && numel(arg) == numel(line1)
                % It is the x-coordinate vector
                xCoords = double(arg);
            elseif isempty(arg)
                 % Handle empty inputs if passed intentionally as placeholders
                 continue;
            else
                error('MATLAB:calHausdorffDist:InvalidInput', ...
                      ['Optional inputs must be either a scalar (percentage) ' ...
                       'or a vector matching the input size (x-coordinates).']);
            end
        end
    end

    % Ensure xCoords are column vectors for processing
    xCoords = xCoords(:);
    line1 = line1(:);
    line2 = line2(:);

    % ---------------------------------------------------------------------
    % 2. Data Preparation (NaN Handling)
    % ---------------------------------------------------------------------
    % Construct point sets (N x 2 matrices: [x, y])
    pointsA = [xCoords, line1];
    pointsB = [xCoords, line2];

    % Remove rows containing NaN in either column
    % We process the sets independently. If point i in Line1 is NaN, that specific
    % point is removed from Set A. It does not invalidate point i in Set B.
    pointsA(any(isnan(pointsA), 2), :) = [];
    pointsB(any(isnan(pointsB), 2), :) = [];

    % Check if valid points remain
    if isempty(pointsA) || isempty(pointsB)
        warning('MATLAB:calHausdorffDist:EmptySet', ...
                'One or both point sets are empty after removing NaNs. Returning NaN.');
        hd = NaN;
        return;
    end

    % ---------------------------------------------------------------------
    % 3. Distance Matrix Calculation
    % ---------------------------------------------------------------------
    % We compute the squared Euclidean distance matrix using implicit expansion.
    % This is generally faster than pdist2 for 1D/2D arrays and removes toolbox dependency.
    
    % A: [Na x 2], B: [Nb x 2]
    % Reshape A to [Na x 1 x 2] and B to [1 x Nb x 2] for broadcasting
    A_diff = reshape(pointsA, size(pointsA, 1), 1, 2);
    B_diff = reshape(pointsB, 1, size(pointsB, 1), 2);
    
    % Compute squared differences: (Ax - Bx)^2 + (Ay - By)^2
    sqDistMat = sum((A_diff - B_diff).^2, 3); 
    
    % ---------------------------------------------------------------------
    % 4. Directed Hausdorff Distances
    % ---------------------------------------------------------------------
    % d(A, B): For every point in A, find the distance to the nearest point in B
    % This corresponds to the minimum along the columns (dimension 2)
    minDist_A_to_B = sqrt(min(sqDistMat, [], 2));
    
    % d(B, A): For every point in B, find the distance to the nearest point in A
    % This corresponds to the minimum along the rows (dimension 1)
    minDist_B_to_A = sqrt(min(sqDistMat, [], 1))'; % Transpose to column vector

    % ---------------------------------------------------------------------
    % 5. Percentile Calculation
    % ---------------------------------------------------------------------
    % Calculate the specified percentile for both directed distances
    h_A_to_B = prctile_custom(minDist_A_to_B, pct);
    h_B_to_A = prctile_custom(minDist_B_to_A, pct);

    % The undirected Hausdorff distance is the maximum of the two directed distances
    hd = max(h_A_to_B, h_B_to_A);

end

function y = prctile_custom(x, p)
%PRCTILE_CUSTOM Helper to calculate percentile without Statistics Toolbox.
%   Uses the standard definition of percentile: the value below which
%   P percent of the observations may be found.
    
    sortedX = sort(x);
    n = length(x);
    
    % Calculate the index
    k = (p/100) * (n - 1) + 1;
    
    floor_k = floor(k);
    ceil_k = ceil(k);
    
    if floor_k == ceil_k
        y = sortedX(k);
    else
        % Linear interpolation
        v1 = sortedX(floor_k);
        v2 = sortedX(ceil_k);
        fraction = k - floor_k;
        y = v1 + fraction * (v2 - v1);
    end
end