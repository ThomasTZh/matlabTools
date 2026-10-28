function [levelOut, metricOut] = otsuNoNan(imgIn)
%otsuNoNan Computes global image threshold using Otsu method, ignoring NaNs.
%
% Description:
%   levelOut = otsuNoNan(imgIn) computes a global threshold levelOut ...
%   from imgIn, completely ignoring any NaN values.
%
%   [levelOut, metricOut] = otsuNoNan(imgIn) also returns the ...
%   effectiveness metric metricOut.
%
% Syntax:
%   levelOut = otsuNoNan(imgIn)
%   [levelOut, metricOut] = otsuNoNan(imgIn)
%
% Input Arguments:
%   imgIn - Input image, specified as an N-D numeric array.
%           Data Types: single | double | int16 | uint8 | uint16
%
% Output Arguments:
%   levelOut  - Normalized threshold value, returned as a numeric scalar
%               in the range [0, 1].
%   metricOut - Effectiveness metric, returned as a numeric scalar in
%               the range [0, 1].
% 
% Reference:
%   N. Otsu, "A Threshold Selection Method from Gray-Level Histograms,"
%   IEEE Transactions on Systems, Man, and Cybernetics, vol. 9, no. 1,
%   pp. 62-66, 1979.
%
% Examples:
%   imgIn = [0.1, 0.5, NaN, 0.8, 0.9];
%   threshLevel = otsuNoNan(imgIn);
% 
% Program by TZ 30 June 2026
% 

% Validate input attributes to ensure unsupported types are rejected
validateattributes(imgIn, {'uint8', 'uint16', 'double', 'single', ...
    'int16'}, {'nonsparse'}, mfilename, 'imgIn', 1);

% Handle empty input arrays immediately to minimize computational cost
if isempty(imgIn)
    levelOut = 0.0;
    metricOut = 0;
    return;
end

% Check if input is a floating point class to optimize NaN filtering
isFloat4img = isa(imgIn, 'double') || isa(imgIn, 'single');

if isFloat4img
    % Filter NaNs only for floating-point arrays (integers cannot be NaN)
    data4otsu = imgIn(~isnan(imgIn));
else
    % For integer types, flatten the array directly to a column vector
    data4otsu = imgIn(:);
end

% Handle edge case where array contained only NaN values
if isempty(data4otsu)
    levelOut = 0.0;
    metricOut = 0;
    return;
end

% Leverage graythresh for robust histogram mapping and Otsu calculation
if nargout <= 1
    levelOut = graythresh(data4otsu);
else
    [levelOut, metricOut] = graythresh(data4otsu);
end
end