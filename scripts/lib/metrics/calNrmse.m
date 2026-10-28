function [meanNrmse, stdNrmse] = calNrmse(inputMat, refMat)
%CALNRMSE Calculates Normalized Root Mean Square Error for stacked images.
%
%   Description:
%   This function computes the mean and standard deviation of the NRMSE 
%   between an input matrix and a reference matrix. The first two 
%   dimensions are treated as spatial image dimensions, while all 
%   subsequent dimensions are treated as stacking axes. 
%
%   Syntax:
%   [meanNrmse, stdNrmse] = calNrmse(inputMat, refMat)
%
%   Input Arguments:
%   inputMat - Multi-dimensional numeric array representing test data.
%   refMat   - Multi-dimensional numeric array representing reference 
%              data. Must be the same size and type as inputMat.
%
%   Output Arguments:
%   meanNrmse - Scalar value representing the mean NRMSE across all 
%               stacked 2D images.
%   stdNrmse  - Scalar value representing the standard deviation of the 
%               NRMSE across all stacked 2D images.
%
%   Examples:
%   refMat = rand(256, 256, 10, 4);
%   inputMat = refMat + 0.1 * randn(size(refMat));
%   [meanNrmse, stdNrmse] = calNrmse(inputMat, refMat);

% Check input arguments
narginchk(2, 2);

% Validate input matrices
validateattributes(inputMat, {'numeric'}, {'nonempty', 'real'}, ...
    'calNrmse', 'inputMat', 1);
validateattributes(refMat, {'numeric'}, {'nonempty', 'real'}, ...
    'calNrmse', 'refMat', 2);

% Ensure dimensions match
if ~isequal(size(inputMat), size(refMat))
    error('calNrmse:sizeMismatch', ...
        'Input matrix and reference matrix must have the same size.');
end

% Extract dimensions and check validity
sizeVec = size(inputMat);
if length(sizeVec) < 2
    error('calNrmse:invalidDims', ...
        'Input must have at least 2 dimensions (image dimensions).');
end

% Prepare constants 4reshaping
numPixels4img = sizeVec(1) * sizeVec(2);
numImgs4stack = numel(inputMat) / numPixels4img;

% Reshape matrices 2 2D arrays: [numPixels4img, numImgs4stack]
reshapedInput = reshape(inputMat, [numPixels4img, numImgs4stack]);
reshapedRef = reshape(refMat, [numPixels4img, numImgs4stack]);

% Calculate error and reference energy 4each image via vectorization
diffMat = reshapedInput - reshapedRef;
errEnergy4img = sum(diffMat.^2, 1);
refEnergy4img = sum(reshapedRef.^2, 1);

% Prevent division by zero by adding a small epsilon 2reference energy
epsVal4div = eps(class(refMat));
nrmseVec = sqrt(errEnergy4img) ./ sqrt(refEnergy4img + epsVal4div);

% Calculate final statistics
meanNrmse = mean(nrmseVec);
stdNrmse = std(nrmseVec);

end