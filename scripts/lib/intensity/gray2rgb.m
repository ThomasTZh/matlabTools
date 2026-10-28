function img4output = gray2rgb(img4input, varargin)
%GRAY2RGB Converts a grayscale image to an RGB image using a colormap.
%
% Description:
%   img4output = gray2rgb(img4input) converts the input grayscale image
%   to an RGB image using the default 'jet' colormap with 256 colors.
%   img4output = gray2rgb(img4input, map4color) allows the user to
%   specify a custom colormap. The colormap can be a character vector,
%   string (e.g., 'hot'), or an N-by-3 numeric matrix.
%
% Syntax:
%   img4output = gray2rgb(img4input)
%   img4output = gray2rgb(img4input, map4color)
%
% Input Arguments:
%   img4input - 2D numeric or logical array representing the grayscale
%               image. Supported classes: uint8, uint16, int16, single,
%               double, logical.
%   map4color - (Optional) Character vector, string scalar, or an
%               N-by-3 numeric array defining the colormap.
%               Default: 'jet'.
%
% Output Arguments:
%   img4output - 3D numeric array (M-by-N-by-3) representing the
%                colored RGB image. The output class is double, with
%                values in the range [0, 1].
%
% Examples:
%   % Example 1: Use default jet colormap
%   img4test = imread('cameraman.tif');
%   rgb4test = gray2rgb(img4test);
%   imshow(rgb4test);
%
%   % Example 2: Use custom character colormap
%   rgb4test2 = gray2rgb(img4test, 'hot');
%
%   % Example 3: Use custom numeric colormap matrix
%   map4custom = [0 0 0; 0.5 0.5 0.5; 1 1 1];
%   rgb4test3 = gray2rgb(img4test, map4custom);

% Define default arguments
if nargin < 2
    map4color = 'jet';
else
    map4color = varargin{1};
end

% Input validation for grayscale image
validateattributes(img4input, ...
    {'numeric', 'logical'}, ...
    {'2d', 'nonempty', 'real'}, ...
    'gray2rgb', 'img4input', 1);

% Parse and validate colormap
if ischar(map4color) || isstring(map4color)
    % Ensure string is handled as char array for feval
    name4map = char(map4color);
    % Generate a 256-level colormap using the specified name
    try
        map4numeric = feval(name4map, 256);
    catch
        error('gray2rgb:invalidName4map', ...
            'The specified colormap name is invalid or not found.');
    end
elseif isnumeric(map4color)
    validateattributes(map4color, ...
        {'numeric'}, ...
        {'2d', 'ncols', 3, '>=', 0, '<=', 1}, ...
        'gray2rgb', 'map4color', 2);
    map4numeric = double(map4color);
else
    error('gray2rgb:invalidType4map', ...
        'Colormap must be a string, char, or an N-by-3 matrix.');
end

% Determine the number of colors in the colormap
count4colors = size(map4numeric, 1);

% Convert grayscale image to indexed image
% gray2ind inherently handles different input classes appropriately
[img4indexed, ~] = gray2ind(img4input, count4colors);

% Convert indexed image to RGB image
% ind2rgb outputs an image of class double in the range [0, 1]
img4output = ind2rgb(img4indexed, map4numeric);

end