function b = medfilt3sym4nan(varargin)
%MEDFILT3SYM4NAN 3-D median filtering ignoring NaNs with symmetric padding.
%   B = MEDFILT3SYM4NAN(A) performs median filtering of the 3-D array A.
%   Each output voxel contains the median value in the 3-by-3-by-3 
%   neighborhood around the corresponding voxel in the input array.
%
%   Standard MEDFILT3 behavior allows NaNs to propagate (bloom) into valid 
%   data regions, corrupting large volumes of data. This function confines 
%   NaNs to their original locations by pre-filling them prior to filtering 
%   and restoring them afterwards.
%
%   B = MEDFILT3SYM4NAN(A, [M N P]) filters array A with a 3-D neighborhood 
%   of size M-by-N-by-P.
%
%   B = MEDFILT3SYM4NAN(..., PADOPT) pads the array boundaries. 
%   PADOPT can be 'zeros', 'symmetric', or 'replicate'.
%   The default PADOPT for MEDFILT3SYM4NAN is 'symmetric'.
%
%   Class Support
%   -------------
%   The input array A must be a 3-D numeric or logical array. The output 
%   array B is of the same class as A.
%
%   Example
%   -------
%       % Create a 3D volume with noise and a block of NaNs
%       vol = rand(50, 50, 50);
%       vol(20:30, 20:30, 20:30) = NaN; 
%       
%       % Compare standard vs NaN-safe filtering
%       volStd = medfilt3(vol);            % NaNs will expand
%       volNan = medfilt3sym4nan(vol);     % NaNs stay confined
%
%       % Visualize the center slice
%       figure; 
%       subplot(1,2,1); imagesc(volStd(:,:,25)); title('Standard medfilt3');
%       subplot(1,2,2); imagesc(volNan(:,:,25)); title('medfilt3sym4nan');
%
%   See also MEDFILT3, FILLMISSING, SMOOTH3.
%   
%   Program by TZ 26/11/2025.

    narginchk(1, 3);

    % 1. Parse and Validate Input
    A = varargin{1};
    validateattributes(A, {'numeric', 'logical'}, {'3d', 'real'}, mfilename, 'A', 1);

    % 2. Default Settings
    mnp = [3 3 3];
    padOpt = 'symmetric';

    % 3. Input Parsing
    if nargin > 1
        arg2 = varargin{2};
        if ischar(arg2) || isstring(arg2)
            padOpt = arg2;
        else
            mnp = arg2;
            validateattributes(mnp, {'numeric'}, ...
                {'vector', 'numel', 3, 'positive', 'integer'}, mfilename, 'MNP', 2);
        end
    end
    if nargin > 2
        padOpt = varargin{3};
    end
    
    padOpt = validatestring(padOpt, {'zeros', 'symmetric', 'replicate'}, mfilename, 'PADOPT');

    % 4. Main Processing
    if isfloat(A)
        nanMask = isnan(A);
        
        if any(nanMask(:))
            % OPTIMIZATION START: Fast Local Mean Imputation
            % Instead of sorting (fillmissing), we use convolution (imboxfilt3).
            
            % Define fill window size (odd integers). 
            % Larger windows bridge larger gaps but blur the fill more.
            % A size roughly 2x the filter kernel is usually robust.
            fillSz = 2 * mnp + 1; 
            
            % Create a safe copy where NaNs are 0
            A0 = A;
            A0(nanMask) = 0;
            
            % Create a validity mask (1 for valid data, 0 for NaN)
            validityMask = double(~nanMask);
            
            % Compute local sum of data and local count of valid pixels
            % imboxfilt3 is highly optimized (O(1) complexity wrt size).
            % We use 'Padding', 'replicate' to handle volume edges gracefully.
            localSum = imboxfilt3(A0, fillSz, 'Padding', 'replicate');
            localCount = imboxfilt3(validityMask, fillSz, 'Padding', 'replicate');
            
            % Avoid division by zero
            localCount(localCount == 0) = 1;
            
            % Compute the local mean
            meanFill = localSum ./ localCount;
            
            % Fill the NaNs in the original matrix with these mean values.
            % This creates a "neutral" background that won't skew the median 
            % excessively compared to the noise floor.
            A(nanMask) = meanFill(nanMask);
            
            % In extremely rare cases where the fill window was entirely empty
            % (massive NaN blocks), remaining NaNs might persist. Zero fill.
            if any(isnan(A(:)))
                A(isnan(A)) = min(A,[],"all","omitmissing");
            end
            % OPTIMIZATION END
            
            % Apply standard median filter
            b = medfilt3(A, mnp, padOpt);
            
            % Restore original NaNs
            b(nanMask) = NaN;
        else
            b = medfilt3(A, mnp, padOpt);
        end
    else
        % Integers do not support NaN
        b = medfilt3(A, mnp, padOpt);
    end
end