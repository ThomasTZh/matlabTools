function maskImg = segMask(tempImg, segLine, varargin)
%SEGMASK Masks a 3D volume based on a 2D segmentation surface.
%   maskImg = SEGMASK(tempImg, segLine) applies a mask to the input 3D image
%   'tempImg' using the surface defined by 'segLine'. By default, pixels
%   "above" the surface (indices < segLine) are masked with NaN.
%
%   maskImg = SEGMASK(tempImg, segLine, setValue) specifies the value used
%   to mask the pixels (default is NaN).
%
%   maskImg = SEGMASK(tempImg, segLine, setValue, maskDir) specifies the
%   masking direction. Options are 'above', 'below', 'left', 'right'.
%   The function automatically detects if 'segLine' defines a Z-surface
%   (X-Y plane) or an X-surface (Z-Y plane) based on dimensions.
%
%   Inputs:
%       tempImg  - 3D numeric array (Z-X-Y).
%       segLine  - 2D numeric array defining the surface indices.
%                  Size must match [X, Y] for Z-masking, or [Z, Y] for X-masking.
%       setValue - (Optional) Scalar value to assign to masked pixels.
%       maskDir  - (Optional) Char array: 'above', 'below', 'left', 'right'.
%
%   Outputs:
%       maskImg  - The masked 3D volume.
%
%   Example:
%       vol = rand(10, 50, 50);
%       surface = 5 * ones(50, 50); % Flat surface at Z=5
%       maskedVol = segMask(vol, surface, 0, 'below');
%
%   See also VALIDATEATTRIBUTES, PERMUTE, SQUEEZE.

%   Program by TZ, 10 Nov 2025.

    %% --- Input Validation ---
    % Use strict validation to ensure data integrity
    validateattributes(tempImg, {'numeric','logical'}, {'3d'}, mfilename,...
        'tempImg', 1);
    validateattributes(segLine, {'numeric'}, {'2d'}, mfilename, 'segLine', 2);
    
    % Squeeze strictly to ensure Z-X-Y format if singleton dims exist
    tempImg = squeeze(tempImg); 
    [szZ, szX, szY] = size(tempImg);
    
    % Determine default values
    if nargin < 3 || isempty(varargin{1})
        setValue = NaN;
    else
        setValue = varargin{1};
    end
    
    if nargin < 4 || isempty(varargin{2})
        % Default direction depends on detected mode (set later if not provided)
        maskDir = ''; 
    else
        maskDir = validatestring(varargin{2}, {'above', 'below', 'left', 'right'});
    end

    %% --- Dimension Analysis & Plane Detection ---
    % Determine if segLine matches the Top/Bottom (X-Y) or Side (Z-Y) dimensions
    szLine = size(segLine);
    
    mode = ''; % 'z-mask' or 'x-mask'
    
    % Case 1: segLine matches [X, Y] (Standard Z-masking)
    if isequal(szLine, [szX, szY])
        mode = 'z-mask';
    elseif isequal(szLine, [szY, szX])
        segLine = segLine'; % Fix orientation
        mode = 'z-mask';
        
    % Case 2: segLine matches [Z, Y] (Side/X-masking)
    elseif isequal(szLine, [szZ, szY])
        mode = 'x-mask';
    elseif isequal(szLine, [szY, szZ])
        segLine = segLine'; % Fix orientation
        mode = 'x-mask';
    else
        error('segMask:DimensionMismatch', ...
            'segLine dimensions %s do not match Image [Z=%d, X=%d, Y=%d] in any orientation.', ...
            mat2str(szLine), szZ, szX, szY);
    end

    % Set default direction if not provided by user
    if isempty(maskDir)
        if strcmp(mode, 'z-mask')
            maskDir = 'above';
        else
            maskDir = 'left';
        end
    end

    %% --- Mask Creation (Implicit Expansion) ---
    % Pre-process the line: clamp values to valid image indices
    segLine = round(segLine);
    
    % Logic:
    % 1. Create a "Ruler" representing the axis we are masking along.
    % 2. Permute "segLine" so it aligns with the OTHER two axes.
    % 3. Use Implicit Expansion (Ruler vs segLine) to build 3D logical mask.
    
    if strcmp(mode, 'z-mask')
        % Masking along Z-axis. Valid dirs: 'above', 'below'
        if ~ismember(maskDir, {'above', 'below'})
            error('For Z-dimension surface (X-Y size), direction must be ''above'' or ''below''.');
        end
        
        segLine(segLine < 1) = 1; 
        segLine(segLine > szZ) = szZ;
        
        % Ruler: [Z, 1, 1] | Surface: [1, X, Y]
        ruler = (1:szZ)'; 
        surface3D = permute(segLine, [3, 1, 2]); 
        
    elseif strcmp(mode, 'x-mask')
        % Masking along X-axis. Valid dirs: 'left', 'right'
        if ~ismember(maskDir, {'left', 'right'})
            error('For X-dimension surface (Z-Y size), direction must be ''left'' or ''right''.');
        end
        
        segLine(segLine < 1) = 1; 
        segLine(segLine > szX) = szX;
        
        % Ruler: [1, X, 1] | Surface: [Z, 1, Y]
        ruler = 1:szX; % Row vector [1, X]
        ruler = reshape(ruler, [1, szX, 1]);
        
        % segLine is [Z, Y], needs to become [Z, 1, Y] to broadcast over X
        surface3D = permute(segLine, [1, 3, 2]); 
    end

    %% --- Apply Mask ---
    % Generate logical mask using implicit expansion
    switch maskDir
        case {'above', 'left'} 
            % 'Left' usually implies index 1 to line (x < line)
            % 'Above' usually implies index 1 to line (z < line)
            myMask = ruler < surface3D;
        case {'below', 'right'}
            myMask = ruler > surface3D;
    end

    maskImg = tempImg;
    maskImg(myMask) = setValue;

end