function [meanScore, stdScore] = calPsnr(testMat, refMat, peakVal)
%calPsnr Computes mean and std of PSNR 4 stacked images.
%
% Description:
%   This function calculates Peak Signal-to-Noise Ratio (PSNR)
%   for multi-dimensional matrices, treating the first two 
%   dimensions as spatial image dimensions and all subsequent 
%   dimensions as stacked images.
%
% Syntax:
%   [meanScore, stdScore] = calPsnr(testMat, refMat)
%   [meanScore, stdScore] = calPsnr(testMat, refMat, peakVal)
%
% Input Arguments:
%   testMat - Test multidimensional array. First 2 dims are image.
%   refMat  - Reference multidimensional array. Matches testMat size.
%   peakVal - (Optional) Peak signal value. Defaults to max of refMat.
%
% Output Arguments:
%   meanScore - Mean of the PSNR scores across all stacked images.
%   stdScore  - Standard deviation of PSNR scores across all stacked images.
%
% Examples:
%   refMat4test = rand(256, 256, 10, 5);
%   testMat4test = refMat4test + 0.05 * randn(256, 256, 10, 5);
%   [meanVal, stdVal] = calPsnr(testMat4test, refMat4test, 1);

% Input validation
arguments
    testMat {mustBeNumeric, mustBeNonempty}
    refMat {mustBeNumeric, mustBeNonempty}
    peakVal (1,1) {mustBeNumeric} = max(refMat(:))
end

% Check if sizes match exactly
if ~isequal(size(testMat), size(refMat))
    error('calcPsnr4ndMatrix:sizeMismatch', ...
        'The size of testMat must equal the size of refMat.');
end

% Convert matrices to double for accurate calculation
testMat2dbl = double(testMat);
refMat2dbl = double(refMat);
peakVal2dbl = double(peakVal);

% Calculate squared error
sqErr = (testMat2dbl - refMat2dbl) .^ 2;

% Calculate Mean Squared Error (MSE) along the first 2 dimensions
mseVal = mean(sqErr, [1, 2], 'omitnan');

% Calculate PSNR for each stacked image
% Use eps to prevent division by zero if MSE is exactly 0
mseVal(mseVal == 0) = eps;
psnrScores = 10 * log10((peakVal2dbl^2) ./ mseVal);

% Flatten the scores to calculate global mean and std across stacked axes
psnrScores2flat = psnrScores(:);

% Output calculations
meanScore = mean(psnrScores2flat, 'omitnan');
stdScore = std(psnrScores2flat, 'omitnan');

end