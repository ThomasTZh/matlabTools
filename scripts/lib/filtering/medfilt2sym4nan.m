function b = medfilt2sym4nan(varargin)
%MEDFILT2SYM4NAN 2-D median filtering ignoring NaNs with symmetric padding.
%   B = MEDFILT2SYM4NAN(A) performs median filtering of the matrix A in two
%   dimensions. Each output pixel contains the median value in the
%   3-by-3 neighborhood around the corresponding pixel in the input
%   image. 
%
%   Unlike the standard MEDFILT2, this function prevents NaNs from 
%   expanding (blooming) into valid data regions. It achieves this by
%   temporarily filling NaNs prior to filtering, then restoring the 
%   original NaN locations in the output.
%
%   B = MEDFILT2SYM4NAN(A, [M N]) filters matrix A with a 2-D neighborhood of
%   size M-by-N.
%
%   B = MEDFILT2SYM4NAN(..., PADOPT) pads the array boundaries. 
%   PADOPT can be 'zeros', 'symmetric', or 'indexed'.
%   The default PADOPT for MEDFILT2SYM4NAN is 'symmetric', whereas the 
%   standard MEDFILT2 defaults to 'zeros'.
%
%   Class Support
%   -------------
%   The input array A must be a 2-D numeric array. The output array B
%   is of the same class as A.
%
%   Example
%   -------
%       % Create a matrix with noise and a block of NaNs
%       A = rand(100);
%       A(40:60, 40:60) = NaN; 
%       
%       % Compare standard vs NaN-safe filtering
%       B_std = medfilt2(A);        % NaNs will expand/blur edges
%       B_nan = medfilt2sym4nan(A);     % NaNs stay confined
%
%       figure; 
%       subplot(1,2,1); imagesc(B_std); title('Standard medfilt2');
%       subplot(1,2,2); imagesc(B_nan); title('medfilt2sym4nan');
%
%   See also MEDFILT2, FILLMISSING, FILTER2, ORDFILT2.

%   Program by TZ 26/11/2025.

    narginchk(1, 3);

    % Parse inputs
    A = varargin{1};
    validateattributes(A, {'numeric', 'logical'}, {'2d', 'real'}, mfilename, 'A', 1);

    % Default settings
    mn = [3 3];
    padopt = 'symmetric'; % Requested default

    % Input parsing logic to handle optional arguments
    if nargin > 1
        % Check if second argument is [m n] or padopt
        if ischar(varargin{2}) || isstring(varargin{2})
            padopt = varargin{2};
        else
            mn = varargin{2};
            validateattributes(mn, {'numeric'}, {'vector', 'numel', 2, 'positive', 'integer'}, mfilename, 'MN', 2);
        end
    end

    if nargin > 2
        padopt = varargin{3};
    end
    
    % Validate padding option
    validStrings = {'zeros', 'symmetric', 'indexed'};
    padopt = validatestring(padopt, validStrings, mfilename, 'PADOPT');

    % Main Processing
    if isfloat(A)
        % Locate NaNs
        nanMask = isnan(A);
        
        if any(nanMask(:))
            % Strategy: Local Mean Imputation via Box Filtering
            
            % Define fill window size.
            % We use 2*MN + 1 to ensure the fill window is large enough to 
            % capture valid data around the edges of NaN holes.
            fillSz = 2 * mn + 1;
            
            % Create copies for convolution
            A0 = A;
            A0(nanMask) = 0;             % NaNs treated as 0 contribution
            validityMask = double(~nanMask); % 1 for Valid, 0 for NaN
            
            % Compute local sum and local count using integral images (O(1))
            % 'imboxfilt' is significantly faster than 'conv2' for large kernels
            localSum = imboxfilt(A0, fillSz, 'Padding', 'replicate');
            localCount = imboxfilt(validityMask, fillSz, 'Padding', 'replicate');
            
            % Protect against division by zero (if a window is purely NaNs)
            localCount(localCount == 0) = 1;
            
            % Compute Mean
            meanFill = localSum ./ localCount;
            
            % Inject calculated means into NaN slots only
            A(nanMask) = meanFill(nanMask);
            
            % Fallback for stubborn NaNs (e.g. image entirely NaN)
            if any(isnan(A(:)))
                A(isnan(A)) = 0;
            end
            % Apply standard median filter
            b = medfilt2(A, mn, padopt);

            % % 1. Fill NaNs to prevent them from influencing the median of neighbors.
            % % We use 'nearest' to act as a local hold, which is robust for median filtering.
            % % We apply it in dimension 2 if dimension 1 leaves NaNs (e.g., entire columns of NaNs).
            % A_filled=fillmissing(A,'nearest',1);
            % A_filled=fillmissing(A_filled,'nearest',2);
            % 
            % % If the entire matrix was NaN or fillmissing couldn't resolve all,
            % % fill remaining with 0 as a safe fallback for calculation.
            % if any(isnan(A_filled(:)))
            %      A_filled(isnan(A_filled)) = 0;
            % end
            % 
            % % 2. Apply standard medfilt2 with the user/default padding
            % b = medfilt2(A_filled, mn, padopt);
            
            % Restore the original NaN holes
            b(nanMask) = NaN;
        else
            % Optimization: No NaNs present, run standard filter
            b = medfilt2(A, mn, padopt);
        end
    else
        % Integers cannot contain NaN, run standard filter directly
        b = medfilt2(A, mn, padopt);
    end

end