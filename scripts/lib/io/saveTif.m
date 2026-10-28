function saveTif(imgData, outFolder, origName, nameSuffix, op4comp)
%SAVETIF Save grayscale or RGB image data as a TIFF file.
%
% Description:
%   Saves a 2D grayscale or 3D RGB image to a specified directory
%   with optional name suffixing and compression options.
%
% Syntax:
%   saveTif(imgData, outFolder, origName)
%   saveTif(imgData, outFolder, origName, nameSuffix)
%   saveTif(imgData, outFolder, origName, nameSuffix, op4comp)
%
% Input Arguments:
%   imgData    - M-by-N or M-by-N-by-3 numeric or logical image matrix.
%   outFolder  - Character vector specifying target directory path.
%   origName   - Character vector of the base filename.
%   nameSuffix - Character vector to append to the base filename.
%   op4comp    - Character vector for TIFF compression type 
%                (e.g., 'none', 'packbits', 'lzw').
%
% Output Arguments:
%   None
%
% Examples:
%   % Save grayscale image without compression
%   saveTif(zeros(100,100), './out', 'grayImg');
%
%   % Save RGB image with LZW compression and a suffix
%   saveTif(rand(100,100,3), './out', 'rgbImg', 'processed', 'lzw');

    % Handle optional input arguments cleanly
    if nargin < 4 || isempty(nameSuffix)
        nameSuffix = '';
    end
    if nargin < 5 || isempty(op4comp)
        op4comp = 'none';
    end

    % Validate input argument structural attributes
    validateattributes(imgData, {'numeric', 'logical'}, {'nonempty'}, ...
        mfilename, 'imgData', 1);
    validateattributes(outFolder, {'char', 'string'}, {'row'}, ...
        mfilename, 'outFolder', 2);
    validateattributes(origName, {'char', 'string'}, {'row'}, ...
        mfilename, 'origName', 3);
    validateattributes(nameSuffix, {'char', 'string'}, {'2d'}, ...
        mfilename, 'nameSuffix', 4);
    validateattributes(op4comp, {'char', 'string'}, {'row'}, ...
        mfilename, 'op4comp', 5);

    % Enforce structural dimensions for grayscale and RGB frameworks
    imgDims = ndims(imgData);
    if imgDims == 3
        if size(imgData, 3) ~= 3
            error('saveTif:InvalidRGB', ...
                'RGB image data must contain exactly 3 channels.');
        end
    elseif imgDims ~= 2
        error('saveTif:InvalidDims', ...
            'Image data must be a 2D or 3D matrix.');
    end

    % 1. Create target directory infrastructure if missing
    if ~isfolder(outFolder)
        try
            wrtdir(outFolder);
            % mkdir(outFolder);
            fprintf('Created new directory: %s\n', outFolder);
        catch errObj
            error('saveTif:DirCreation', ...
                'Could not create directory: %s\n%s', ...
                outFolder, errObj.message);
        end
    end

    % 2. Isolate file path roots to prevent extension stacking
    [~, baseName, ~] = fileparts(origName);

    % 3. Standardize string concatenation operations
    if ~isempty(nameSuffix)
        newName = sprintf('%s_%s.tif', baseName, nameSuffix);
    else
        newName = sprintf('%s.tif', baseName);
    end
    fullPath = fullfile(outFolder, newName);

    % 4. Write verified image payload to target destination
    imwrite(imgData, fullPath, 'Compression', op4comp);

end