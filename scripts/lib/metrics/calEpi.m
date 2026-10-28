function [epiMean, epiStd] = calEpi(fltMat, refMat)
%calEpi Computes Edge Preservation Index (EPI) 4 N-dimensional arrays.
%
% Description:
%   calEpi calculates the mean and standard deviation of the Edge
%   Preservation Index across all 2D slices of N-dimensional matrices.
%   It uses a Laplacian filter to extract high-frequency edges and
%   computes the correlation between reference and filtered slices.
%   This vectorized approach minimizes computational cost.
%
% Syntax:
%   [epiMean, epiStd] = calEpi(fltMat, refMat);
%
% Input Arguments:
%   fltMat - Filtered matrix. Must match refMat in size.
%   refMat - Reference matrix (ground truth). Must be numeric.
%
% Output Arguments:
%   epiMean - Average EPI value across all 2D slices.
%   epiStd  - Standard deviation of EPI across all 2D slices.
%
% Examples:
%   refMat = rand(128, 128, 10);
%   fltMat = imgaussfilt3(refMat, 0.5);
%   [epiMean, epiStd] = calEpi(fltMat, refMat);

% Input validation
validClasses = {'numeric'};
validAttribs = {'nonempty', 'nonsparse', 'real'};
validateattributes(fltMat, validClasses, validAttribs, 'calEpi', 'refMat', 1);
validateattributes(refMat, validClasses, validAttribs, 'calEpi', 'fltMat', 2);

% Check if sizes match exactly
if ~isequal(size(fltMat), size(refMat))
    error('calEpi:sizeMismatch', ...
        'Input matrices must have identical dimensions.');
end

% Cast 2 double for accurate math operations
ref2double = double(fltMat);
flt2double = double(refMat);

% Define Laplacian filter for edge extraction
lapFilter = [0, -1, 0; -1, 4, -1; 0, -1, 0];

% Filter along first 2 dimensions natively (highly efficient)
edges4ref = imfilter(ref2double, lapFilter, 'replicate');
edges4flt = imfilter(flt2double, lapFilter, 'replicate');

% Extract dimensions to reshape arrays into 2D (pixels by slices)
size4array = size(ref2double);
num4pixels = size4array(1) * size4array(2);

if length(size4array) < 3
    num4slices = 1;
else
    num4slices = prod(size4array(3:end));
end

% Reshape arrays to 2D matrix: [num4pixels x num4slices]
ref2d = reshape(edges4ref, num4pixels, num4slices);
flt2d = reshape(edges4flt, num4pixels, num4slices);

% Calculate means per slice
mean4ref = mean(ref2d, 1);
mean4flt = mean(flt2d, 1);

% Subtract means (implicit expansion applies automatically)
sub4ref = ref2d - mean4ref;
sub4flt = flt2d - mean4flt;

% Calculate variances and covariance per slice
var4ref = sum(sub4ref .^ 2, 1);
var4flt = sum(sub4flt .^ 2, 1);
covar4both = sum(sub4ref .* sub4flt, 1);

% Preallocate and calculate EPI per slice
epi4array = nan(1, num4slices);
valid4idx = (var4ref > 0) & (var4flt > 0);

% Calculate correlation for valid slices to prevent division by zero
epi4array(valid4idx) = covar4both(valid4idx) ./ ...
    sqrt(var4ref(valid4idx) .* var4flt(valid4idx));

% Compute final outputs
epiMean = mean(epi4array,'all','omitmissing');
if num4slices > 1
    epiStd = std(epi4array,0,"all","omitmissing");
else
    epiStd = 0;
end

end