function [imgOut] = imflatfield4nan(imgIn, sigma4filter)
%imflatfield4nan Applies adaptive intensity adjustment.
%
% Description:
%   Utilizes MATLAB's imflatfield to estimate and normalize the local 
%   background via Gaussian smoothing.
%
% Syntax:
%   [imgOut] = imflatfield4nan(imgIn, sigma4filter)
%
% Input Arguments:
%   imgIn        - Numeric array (double). Input image or volume.
%   sigma4filter - Scalar double. Standard deviation for the Gaussian
%                  filter. Larger values track slower intensity changes.
%                  A good starting point for OCT is usually 30 to 50.
%
% Output Arguments:
%   imgOut       - Numeric array (double). Intensity-adjusted data.
%
% Examples:
%   adjustedVol = flattenIntensity4oct(montageArray, 30);

% Validate inputs for robust execution
validateattributes(imgIn, {'double'}, {'real'}, ...
    'imflatfield4nan', 'imgIn');
validateattributes(sigma4filter, {'double'}, {'scalar', 'positive'}, ...
    'imflatfield4nan', 'sigma4filter');

% Isolate NaNs to prevent filter bleeding or mathematical errors
nanMask = isnan(imgIn);

% Temporarily replace NaNs with the global mean to stabilize filter edges
mean4img = mean(imgIn, 'all', 'omitnan');
imgIn(nanMask) = mean4img;

% Apply native flat-field correction 2 adjust intensity adaptively
imgOut = imflatfield(imgIn, sigma4filter);

% Reapply the NaN mask to preserve structural boundaries
imgOut(nanMask) = NaN;

end