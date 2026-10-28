function S = meanmax(A, n, dim, nanflag)

% MEANMAX Compute the mean of the n largest elements of an array.
%
% S = MEANMAX(A, n) computes the mean of the n largest elements along
% the first nonsingleton dimension of A.
%
% S = MEANMAX(A, n, dim) operates along the specified dimension.
%
% S = MEANMAX(A, n, dim, nanflag) controls the treatment of NaN values.
% nanflag can be "includenan" or "omitnan".
%
% If n exceeds the number of elements along dim, all available elements
% along that dimension are considered.
%
%   Example 1:
%       M = [1, NaN, 7; 
%            2, 5, 8; 
%            3, 6, 9];
%       % top 2 of col 2 (6, 5). (NaN is sorted to bottom)
%       result = meanmax(M, 2, 1, 'includenan'); 
%
%   Example 2:
%       % Sum top values ignoring NaNs
%       V = [NaN, 10, 5, NaN];
%       % Top 3 sorted are: 10, 5, NaN.
%       result = meanmax(V, 3, 2, 'omitnan');
%
%   See also SUMMAX, SUM, SORT, MAX.

%   Program by TZ 02 Sep 2026

% Validate input arguments.
arguments
    A
    n (1,1) {mustBeInteger, mustBePositive}
    dim {mustBeInteger, mustBePositive} = []
    nanflag (1,1) string ...
        {mustBeMember(nanflag, {'includenan', 'omitnan'})} = ...
        'includenan'
end

% Use the first nonsingleton dimension when dim is not specified.
% For scalar inputs, use dimension 1.
if isempty(dim)
    dim = find(size(A) > 1, 1);
    if isempty(dim)
        dim = 1;
    end
end

% Limit the number of selected elements to the available number of
% elements along the operating dimension.
dimSize = size(A, dim);
if n > dimSize
    k = dimSize;
else
    k = n;
end

% Sort values in descending order along the operating dimension.
% Place NaN values at the end so that finite values are preferentially
% included among the largest k elements.
sortedA = sort(A, dim, 'descend', ...
    'MissingPlacement', 'last');

% Construct a dynamic subscript list that spans all dimensions while
% selecting only the first k elements along the operating dimension.
indices = repmat({':'}, 1, ndims(sortedA));
indices{dim} = 1:k;

% Extract the k largest elements along the operating dimension.
topValues = sortedA(indices{:});

% Compute the mean of the selected values using the requested NaN
% handling behaviour.
S = mean(topValues, dim, nanflag);

end