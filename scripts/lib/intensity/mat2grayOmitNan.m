function I = mat2grayOmitNan(A,limits)
%MAT2GRAYOMITNAN Convert matrix to intensity image.
%   I = MAT2GRAYOMITNAN(A,[AMIN AMAX]) converts the matrix A to the intensity
%   image I. The returned matrix I contains values in the range 0.0 (black) to
%   1.0 (full intensity or white).  AMIN and AMAX are the values in A that
%   correspond to 0.0 and 1.0 in I.  Values less than AMIN become 0.0, and
%   values greater than AMAX become 1.0.
%
%   I = MAT2GRAYOMITNAN(A) sets the values of AMIN and AMAX to the minimum and
%   maximum values in A.
%
%   Class Support
%   -------------
%   The input array A can be logical or numeric. The output image I is double.
%
%   Example
%   -------
%       I = imread('rice.png');
%       J = filter2(fspecial('sobel'), I);
%       K = mat2gray(J);
%       figure, imshow(I), figure, imshow(K)
%
%   See also MAT2GRAY, GRAY2IND, IND2GRAY, RGB2GRAY.

%   Program by TZ 06 Nov 2025

%% same as mat2gray
validateattributes(A,{'logical','uint8', 'uint16', 'uint32',...
    'int8', 'int16', 'int32','single', 'double'},...
    {},mfilename,'A',1);
myClass=class(A);
if nargin == 1
    % Calculate limits, **efficiently ignoring NaN values**.
    % This is the critical fix.
    A_min = min(A(:),[], 'omitnan');
    A_max = max(A(:),[], 'omitnan');

    if isnan(A_min)
        % This handles the case where A is all NaN
        limits = [0 1];
    else
        limits = double([A_min A_max]);
    end
    % NOTE: The original GPU code (gpucoder.reduce) did not
    % ignore NaNs and would fail. A more complex GPU-specific
    % reduction would be needed to replicate 'omitnan'.
else
    validateattributes(limits,{'logical','uint8', 'uint16', 'uint32','int8',...
        'int16', 'int32','single', 'double'},{'numel',2},mfilename,'LIMITS',2);
    limits=double(limits);
end

%% Scaling Logic
if limits(2) == limits(1)
    % Constant Image (or all non-NaN values are the same)
    % The official mat2gray returns zeros for a constant image.
    I = zeros(size(A), myClass);

    % We must manually restore NaNs *only* in this case,
    % because zeros() overwrote them.
    I(isnan(A)) = nan;
else
    % Standard linear scaling
    delta = 1 / (limits(2) - limits(1));
    I = imlincomb(delta, A, -limits(1)*delta, myClass);

    % Clip the result.
    I(I < 0) = 0;
    I(I > 1) = 1;
end

end

