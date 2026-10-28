function [r, c] = coords2loc(r0, c0, x, y)
% COORDS2LOC Converts Cartesian coordinates to matrix row/column indices.
%
%   [r, c] = COORDS2LOC(r0, c0, x, y) converts Cartesian (x, y) coordinates
%   back into matrix subscripts (row, col) relative to a specified origin.
%   This is the inverse operation of LOC2COORDS.
%
%   Inputs:
%       r0 - The row index acting as the Y-origin.
%       c0 - The column index acting as the X-origin.
%       x  - The Cartesian X-coordinate(s).
%       y  - The Cartesian Y-coordinate(s).
%
%   Outputs:
%       r  - The calculated row index/indices.
%       c  - The calculated column index/indices.
%
%   Example:
%       % Find matrix index for point (20, -50) relative to center (384, 384)
%       [r, c] = coords2loc(384, 384, 20, -50);

    % Solve for row: y = -(r - r0)  =>  -y = r - r0  =>  r = r0 - y
    r = r0 - y;
    
    % Solve for col: x = c - c0  =>  c = c0 + x
    c = c0 + x;
end