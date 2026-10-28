function normVolume = normPrctile(vol, processDims, pLow, pHigh, subRatio)
% normPrctile  Robust percentile-based normalization with subsampling support.
%
%   Description:
%       Normalizes an N-dimensional volume by calculating percentiles along
%       specified dimensions. It scales the data to the range [0, 1] based on
%       robust floor (pLow) and ceiling (pHigh) statistics.
%
%       Features:
%       1. Flexible Dimension Processing: Can normalize global volume ('all'),
%          per layer, per row, etc.
%       2. Subsampling: Accelerates percentile calculation on large datasets 
%          by processing a random subset of pixels.
%       3. Implicit Expansion: Optimized memory usage during scaling.
%
%   Syntax:
%       normVolume = normPrctile(vol, processDims)
%       normVolume = normPrctile(vol, processDims, pLow, pHigh)
%       normVolume = normPrctile(vol, processDims, pLow, pHigh, subRatio)
%
%   Input Arguments:
%       vol         - (numeric) Input N-D array.
%       processDims - (int/string) Dimensions to compute statistics over.
%                     Can be a scalar, vector, or 'all'.
%                     e.g., [2,3] calculates stats across dims 2 and 3 
%                     (preserving dim 1).
%       pLow        - (optional) Lower percentile (floor). Default: 1.
%       pHigh       - (optional) Upper percentile (ceiling). Default: 99.
%       subRatio    - (optional) Subsampling ratio between 0 and 1. 
%                     Default: 1 (use all data). 
%                     Use e.g. 0.05 to use only 5% of pixels for stats.
%
%   Output Arguments:
%       normVolume  - (numeric) Normalized volume [0, 1].
%
%   Examples:
%       % 1. Normalize global volume (all pixels pooled)
%       nv = normPrctile(vol, 'all');
%
%       % 2. Normalize per layer (Dim 1), aggregating over Dims 2,3
%       nv = normPrctile(vol, [2, 3], 1, 99);
%
%       % 3. Fast approximation using only 10% of pixels
%       nv = normPrctile(vol, [2, 3], 1, 99, 0.1);

    %% 1. Input Validation and Parsing
    narginchk(2, 5);
    
    validateattributes(vol, {'numeric'}, {'real', 'nonempty'}, ...
        'normPrctile', 'vol', 1);

    % Handle 'all' or string inputs for dimensions
    if (ischar(processDims) || isstring(processDims)) && strcmpi(processDims, 'all')
        reduceDims = 1:ndims(vol);
    else
        validateattributes(processDims, {'numeric'}, {'vector', 'positive', 'integer'}, ...
            'normPrctile', 'processDims', 2);
        reduceDims = processDims;
    end
    
    % Optional Arguments Defaults
    if nargin < 3 || isempty(pLow), pLow = 1; end
    if nargin < 4 || isempty(pHigh), pHigh = 99; end
    if nargin < 5 || isempty(subRatio), subRatio = 1; end

    % Validation for optional args
    validateattributes(pLow, {'numeric'}, {'scalar', '>=', 0, '<', 100}, ...
        'normPrctile', 'pLow', 3);
    validateattributes(pHigh, {'numeric'}, {'scalar', '>', pLow, '<=', 100}, ...
        'normPrctile', 'pHigh', 4);
    validateattributes(subRatio, {'numeric'}, {'scalar', '>', 0, '<=', 1}, ...
        'normPrctile', 'subRatio', 5);

    %% 2. Data Preparation (Permute & Reshape Strategy)
    % To support subsampling and fast 'prctile' along arbitrary dimensions,
    % we reshape the data into a 2D matrix: [KeptDims x ProcessDims].
    
    volSize = size(vol);
    allDims = 1:ndims(vol);
    
    % Identify dimensions to keep (preserve structure)
    keepDims = setdiff(allDims, reduceDims);
    
    % If keeping dimensions, we must align them for efficient processing
    if ~isempty(keepDims)
        % Move kept dimensions to front, reduction dimensions to back
        permOrder = [keepDims, reduceDims];
        volPerm = permute(vol, permOrder);
        
        % Calculate sizes for 2D reshape
        numKeptElements = prod(volSize(keepDims));
        numReduceElements = prod(volSize(reduceDims));
        
        % Reshape to [KeptElements x ReduceElements]
        % Rows = separate entities (e.g., layers); Cols = data to aggregate
        data2Process = reshape(volPerm, numKeptElements, numReduceElements);
        
        % Target size for reshaping stats back to original volume shape
        % Set reduced dims to 1, keep others as is
        targetSize = volSize;
        targetSize(reduceDims) = 1;
        
    else
        % Case: 'all' dimensions are being reduced
        data2Process = vol(:)'; % 1 x TotalElements
        targetSize = ones(1, ndims(vol)); % Scalar output
    end

    %% 3. Subsampling (Optimization)
    % Sorting is expensive. If subRatio < 1, pick random columns.
    if subRatio < 1
        nCols = size(data2Process, 2);
        nSub = max(1, round(nCols * subRatio)); % Ensure at least 1 sample
        
        % Generate random indices
        % 'randperm' can be slow for massive N; 'randi' is faster with replacement
        idx = randi(nCols, 1, nSub);
        
        statsData = data2Process(:, idx);
    else
        statsData = data2Process;
    end

    %% 4. Statistic Calculation (Robust Min/Max)
    % Calculate percentiles along dim 2 (columns)
    % Result is [numKeptElements x 1]
    
    lvlMinVec = prctile(statsData, pLow, 2);
    lvlMaxVec = prctile(statsData, pHigh, 2);
    
    % Reshape stats back to [d1, 1, d3, 1...] to align with original 'vol'
    lvlMin = reshape(lvlMinVec, targetSize);
    lvlMax = reshape(lvlMaxVec, targetSize);

    %% 5. Normalization
    % Background Subtraction (Implicit Expansion)
    normVolume = vol - lvlMin;
    normVolume(normVolume < 0) = 0;
    
    % Dynamic Range Calculation
    dynRange = lvlMax - lvlMin;
    
    % Safety: avoid division by zero
    dynRange(dynRange <= 0) = eps;
    
    % Scaling
    normVolume = normVolume ./ dynRange;
    normVolume(normVolume > 1) = 1;

end