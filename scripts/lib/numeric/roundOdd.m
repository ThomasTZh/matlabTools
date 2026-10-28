function Y = roundOdd(X)
%ROUNDODD Round to nearest odd integer.
%   Y = ROUNDODD(X) rounds each element in array X to the nearest odd 
%   integer.
%
%   The function uses standard rounding logic. If X is equidistant between 
%   two odd integers (e.g., an even integer like 2), it rounds away from 
%   zero to the next magnitude odd integer (e.g., 2 becomes 3, -2 becomes -3).
%
%   Class Support
%   -------------
%   The input array X can be numeric. The output Y preserves the class 
%   of the input X if possible, or returns double.
%
%   Example
%   -------
%       X = [1.9, 2, 2.1, 4, -2];
%       Y = roundOdd(X)
%       % Result:
%       % Y = [1, 3, 3, 5, -3]
%
%   See also ROUND, CEIL, FLOOR, FIX, MOD.

%   Program by TZ 06 Nov 2025

% Check for numeric input
validateattributes(X, {'numeric'}, {}, mfilename, 'X', 1);

% Core logic: Round to nearest odd
% This formula shifts the number, rounds to nearest integer, then shifts back
    Y = 2 * round((X - 1) / 2) + 1;
end