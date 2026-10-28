function mae = calMAE(vec1, vec2)
%CALMAE Calculates Mean Absolute Error (MAE) excluding NaN values.
%   MAE = CALMAE(VEC1, VEC2) computes the mean absolute error between two 1D
%   numeric arrays, VEC1 and VEC2. Pairs of elements where either input contains
%   a NaN are excluded from the calculation.
%
%   This function is optimized for performance and robustness, utilizing
%   built-in MATLAB functions to handle missing data efficiently without
%   explicit loops.
%
%   Inputs:
%       vec1 - First input array (1D numeric vector)
%       vec2 - Second input array (1D numeric vector)
%
%   Outputs:
%       mae  - Mean Absolute Error (scalar double). Returns NaN if no 
%              valid pairs exist (e.g., all inputs are NaN).
%
%   Example:
%       v1 = [1.0, 2.0, NaN, 4.0, 5.0];
%       v2 = [1.1, 2.1, 3.0, NaN, 5.2];
%       errorVal = calMAE(v1, v2);
%       % Result matches mean(abs([1.0-1.1, 2.0-2.1, 5.0-5.2]))
%
%   See also MEAN, ABS, VALIDATEATTRIBUTES.

%   Program by TZ, 02 Dec 2025.

    % 1. Input Validation
    % Validate that inputs are numeric, real, and 1D vectors.
    % We do not enforce 'finite' because NaNs are expected and handled.
    validateattributes(vec1, {'numeric'}, {'real', 'vector', 'nonempty'}, ...
        mfilename, 'vec1', 1);
    validateattributes(vec2, {'numeric'}, {'real', 'vector', 'nonempty'}, ...
        mfilename, 'vec2', 2);

    % 2. Size Consistency Check
    % Ensure both vectors have the same number of elements.
    if numel(vec1) ~= numel(vec2)
        error('calculateMAE:InputSizeMismatch', ...
            'Input vectors must have the same number of elements.');
    end

    % 3. Efficient Computation
    % Force inputs to column vectors to ensure element-wise subtraction
    % works correctly regardless of orientation (row vs column).
    diffAbs = abs(vec1(:) - vec2(:));

    % Calculate mean using the native 'omitnan' flag for maximum efficiency.
    % If a pair involves a NaN, the result of the subtraction is NaN, 
    % and 'omitnan' excludes it from both the sum and the element count.
    mae = mean(diffAbs, 'omitnan');

end