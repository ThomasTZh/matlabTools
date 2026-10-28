function r = rnz(A)
%RNZ Ratio of nonzero elements in an array.
%   R = RNZ(A) returns the fraction of nonzero elements in A, defined as
%   NNZ(A)/NUMEL(A). For nonempty A, R lies in the interval [0, 1].
%
%   NaN and Inf values are not equal to zero, so they count as nonzero.
%   An empty A returns NaN, because the ratio is 0/0.
%
%   Input Arguments
%     A - Input array
%       Numeric (single, double, and all integer classes), logical,
%       duration, or calendarDuration array, of any size or shape.
%       Complex, sparse, GPU, distributed, and tall arrays are accepted
%       to the same extent as by NNZ. Cell, string, and character arrays
%       are not supported.
%
%   Output Arguments
%     R - Fraction of nonzero elements, returned as a double scalar.
%       R is NaN when A is empty.
%
%   Examples
%     rnz([1 0 0 4])       % 0.5
%     rnz([1 2; 0 0])      % 0.5
%     rnz(NaN)             % 1
%     rnz([])              % NaN
%
%     % Density of a sparse matrix (as in the NNZ documentation example)
%     X = delsq(numgrid('L',20));
%     rnz(X)               % about 0.0194
%
%   See also NNZ, NUMEL, SPY.

    % NNZ counts nonzeros in one built-in pass without forming a temporary
    % logical array. For sparse A the cost scales with NNZ(A) rather than
    % NUMEL(A), which is why this is preferable to SUM(A ~= 0, 'all').
    % The empty case needs no branch: NNZ([])/NUMEL([]) is 0/0 = NaN.
    r = nnz(A) / numel(A);
end