function [x, y] = loc2coords(r0, c0, r, c)
% LOC2COORDS Converts matrix row/column indices to Cartesian coordinates.
%
%   [x, y] = LOC2COORDS(r0, c0, r, c) converts matrix subscripts (row, col)
%   into Cartesian (x, y) coordinates relative to a specified origin point.
%   This function accounts for the difference in Y-axis direction between
%   images (Y increases down) and Cartesian graphs (Y increases up).
%
%   Inputs:
%       r0 - The row index acting as the Y-origin (0,0).
%       c0 - The column index acting as the X-origin (0,0).
%       r  - The target row index/indices to convert.
%       c  - The target column index/indices to convert.
%
%   Outputs:
%       x  - Cartesian X-coordinate(s).
%       y  - Cartesian Y-coordinate(s).
%
%   Example:
%       % Find coordinates of pixel (100, 50) relative to center (384, 384)
%       [x, y] = loc2coords(384, 384, 100, 50);
    
    % Calculate X distance (Columns increase right, X increases right)
    x = (c - c0);
    
    % Calculate Y distance (Rows increase down, Y increases up)
    % The negative sign flips the axis direction.
    y = -(r - r0);
end