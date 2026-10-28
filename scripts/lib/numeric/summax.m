function S = summax(A, n, dim, nanflag)
%SUMMAX Calculate the sum of the top n values along a specified dimension.
%   S = SUMMAX(A, N) returns the sum of the largest N elements of array A
%   along the first array dimension whose size does not equal 1. NaNs are
%   treated as missing values and placed at the end of the sort order.
%
%   S = SUMMAX(A, N, DIM) sums the largest N elements along the dimension
%   specified by DIM.
%
%   S = SUMMAX(A, N, DIM, NANFLAG) specifies how NaN (Not-A-Number) 
%   values are treated in the summation.
%       'includenan' - (Default) The sum of elements containing NaN is NaN.
%       'omitnan'    - The sum of elements is calculated ignoring NaNs.
%
%   Inputs:
%       A       - Input array.
%       N       - Number of top elements to sum.
%       DIM     - (Optional) Dimension to operate along. 
%                 Use [] to let the function select the first non-singleton
%                 dimension.
%       NANFLAG - (Optional) 'includenan' or 'omitnan'. 
%
%   Outputs:
%       S       - Sum of the top N values.
%
%   Example 1:
%       M = [1, NaN, 7; 
%            2, 5, 8; 
%            3, 6, 9];
%       % Sum top 2 of col 2 (6, 5) -> 11. (NaN is sorted to bottom)
%       result = summax(M, 2, 1, 'includenan'); 
%
%   Example 2:
%       % Sum top values ignoring NaNs
%       V = [NaN, 10, 5, NaN];
%       % Top 3 sorted are: 10, 5, NaN.
%       % 'omitnan' sums 10+5+0 = 15.
%       result = summax(V, 3, 2, 'omitnan');
%
%   See also MEANMAX, SUM, SORT, MAX.

%   Program by TZ 26 Nov 2025


    % Argument validation (MATLAB R2019b and later)
    arguments
        A
        n (1,1) {mustBeInteger, mustBePositive}
        dim {mustBeInteger, mustBePositive} = []
        nanflag (1,1) string {mustBeMember(nanflag, {'includenan', 'omitnan'})} = 'includenan'
    end

    % Determine dimension if not specified or if empty placeholder passed
    if isempty(dim)
        dim = find(size(A) > 1, 1);
        if isempty(dim)
            dim = 1;
        end
    end

    % Determine the actual number of elements to sum
    dimSize = size(A, dim);
    if n > dimSize
        k = dimSize;
    else
        k = n;
    end

    % Step 1: Sort descending, ensuring NaNs are at the end (bottom)
    % 'MissingPlacement', 'last' ensures NaNs don't occupy "top" slots unless necessary
    sortedA = sort(A, dim, 'descend', 'MissingPlacement', 'last');

    % Step 2: Create dynamic indices to select the top k elements
    indices = repmat({':'}, 1, ndims(sortedA));
    indices{dim} = 1:k;

    % Step 3: Extract the top k values
    topValues = sortedA(indices{:});

    % Step 4: Sum these values using the specified NaN flag
    S = sum(topValues, dim, nanflag);

end