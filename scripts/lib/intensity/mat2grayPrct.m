function I = mat2grayPrct(A, limits, nanflag)
%MAT2GRAYPRCT Convert matrix to grayscale image using percentile limits.
%   I = MAT2GRAYPRCT(A, LIMITS) converts the matrix A to an intensity image
%   I by scaling the values of A between the percentiles specified in
%   LIMITS.
%
%   I = MAT2GRAYPRCT(A, LIMITS, NANFLAG) specifies how NaN values are
%   treated. NANFLAG can be 'omitnan' (default) or 'includenan'.
%   'omitmissing' is accepted as an alias for 'omitnan'.
%
%   Inputs:
%       A        - Numeric matrix or array to be converted.
%       LIMITS   - 2-element numeric vector [P1, P2] specifying the lower
%                  and upper percentile limits (0 to 100). Values in A less
%                  than the P1-th percentile are clipped to 0; values
%                  greater than the P2-th percentile are clipped to 1.
%       NANFLAG  - (Optional) String or char array specifying NaN behavior.
%                  Options: 'omitnan' (default), 'includenan', 'omitmissing'.
%
%   Outputs:
%       I        - Intensity image with values in the range [0, 1].
%
%   Example:
%       A = randn(100, 100);
%       % Scale based on the 5th and 95th percentiles, omitting NaNs
%       I = mat2grayPrct(A, [5, 95], 'omitnan');
%
%   See also MAT2GRAY, MAT2GRAYOMITNAN, PRCTILE.

%   program by TZ 02 Dec 2025

    %% Input Validation
    arguments
        A {mustBeNumeric, mustBeReal}
        limits (1,2) {mustBeNumeric, mustBeReal, mustBeInRange(limits, 0, 100)}
        nanflag (1,1) string {mustBeMember(nanflag, ["omitnan", "includenan", "omitmissing", "includemissing"])} = "omitnan"
    end

    %% Normalize Inputs
    % Map 'omitmissing' (modern MATLAB syntax) to 'omitnan' (legacy/specific syntax)
    if strcmpi(nanflag, "omitmissing")
        nanflag = "omitnan";
    elseif strcmpi(nanflag, "includemissing")
        nanflag = "includenan";
    end

    %% Calculate Percentiles
    p1 = limits(1);
    p2 = limits(2);
    
    % Ensure limits are sorted (low, high) just in case user swapped them
    if p1 > p2
        temp = p1;
        p1 = p2;
        p2 = temp;
    end

    % Calculate intensity limits from data
    % prctile naturally handles 'omitnan' behavior by default in most versions,
    % but we are explicit here if needed.
    lowVal  = prctile(A(:), p1);
    highVal = prctile(A(:), p2);

    %% Convert to Grayscale
    switch nanflag
        case 'omitnan'
            % Assumes user has a custom function 'mat2grayOmitNan' on path
            if exist('mat2grayOmitNan', 'file') == 2
                 I = mat2grayOmitNan(A, [lowVal, highVal]);
            else
                 % Fallback if the custom function is missing: 
                 % Standard mat2gray propagates NaNs. If you want them 0, 
                 % you might do: I = mat2gray(A, ...); I(isnan(I)) = 0;
                 warning('mat2grayPrct:FunctionNotFound', ...
                     'Custom function mat2grayOmitNan not found. Using standard mat2gray.');
                 I = mat2gray(A, [lowVal, highVal]);
            end
        case 'includenan'
            I = mat2gray(A, [lowVal, highVal]);
    end
end