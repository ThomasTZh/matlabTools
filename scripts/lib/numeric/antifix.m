function y = antifix(x)
%ANTIFIX Rounds elements away from zero to the nearest integer.
%
%   Description:
%   y = ANTIFIX(x) returns an array y with elements rounded away from
%   zero. For positive x, it behaves like ceil(x). For negative x, it
%   behaves like floor(x). For complex x, it scales magnitude away from
%   zero.
%
%   Syntax:
%   y = antifix(x)
%
%   Input Arguments:
%   x - Input array, specified as a numeric array. Can be real or complex.
%
%   Output Arguments:
%   y - Output array of the same size and data type as x.
%
%   Examples:
%   % Example 1: Rounding real numbers
%   x = [-1.5, -0.2, 0, 0.2, 1.5];
%   y = antifix(x) % Returns [-2, -1, 0, 1, 2]
%
%   See also FIX, CEIL, FLOOR, ROUND.

%   Program by TZ 29 June 2026

%   Check input arguments for validity
narginchk(1, 1);
validateattributes(x, {'numeric'}, {}, 'antifix', 'x', 1);

%   Compute the antifix operation
%   Uses sign and abs for robust handling of real and complex inputs
y = sign(x) .* ceil(abs(x));

end