function outputVolume = imsharpen3(inputVolume, varargin)
%IMSHARPEN3 Sharpen a 3-D grayscale volume using unsharp masking.
%
%   outputVolume = imsharpen3(inputVolume)
%   outputVolume = imsharpen3(inputVolume, 'Radius', radius)
%   outputVolume = imsharpen3(inputVolume, 'Amount', amount)
%   outputVolume = imsharpen3(inputVolume, 'Threshold', threshold)
%
%   Description
%   -----------
%   Sharpens a 3-D grayscale volume using Gaussian unsharp masking:
%
%       sharpened = input + amount .* (input - blurred)
%
%   NaN and Inf values are excluded from the Gaussian averaging and are
%   restored unchanged in the output. This prevents missing voxels from
%   contaminating surrounding voxels.
%
%   The finite minimum and maximum intensities of the input are preserved.
%   No normalization or intensity rescaling is performed.
%
%   Input Arguments
%   ---------------
%   inputVolume
%       Real numeric grayscale volume.
%
%   Name-Value Arguments
%   --------------------
%   Radius
%       Gaussian standard deviation. Default is 1. May be either a
%       positive scalar or a three-element vector [sigmaY sigmaX sigmaZ].
%
%   Amount
%       Sharpening strength. Default is 0.8. Must be nonnegative.
%
%   Threshold
%       Minimum detail magnitude to sharpen, expressed as a fraction of
%       the finite input dynamic range. Default is 0. Must be in [0, 1].
%
%   Output Arguments
%   ----------------
%   outputVolume
%       Sharpened volume with the same size and class as inputVolume.
%
%   Requires Image Processing Toolbox (imgaussfilt3).

    supportedClasses = {'single', 'double', 'int8', 'uint8', ...
        'int16', 'uint16', 'int32', 'uint32'};

    if ~ismember(class(inputVolume), supportedClasses)
        error('imsharpen3:UnsupportedClass', ...
            'inputVolume must have a supported numeric data type.');
    end

    if ~isreal(inputVolume) || issparse(inputVolume)
        error('imsharpen3:InvalidInput', ...
            'inputVolume must be a real, nonsparse numeric array.');
    end

    if ndims(inputVolume) > 3
        error('imsharpen3:InvalidDimensions', ...
            'inputVolume must be a 3-D grayscale volume.');
    end

    parser = inputParser;
    parser.FunctionName = mfilename;

    addParameter(parser, 'Radius', 1, @isValidRadius);
    addParameter(parser, 'Amount', 0.8, @isValidAmount);
    addParameter(parser, 'Threshold', 0, @isValidThreshold);

    parse(parser, varargin{:});

    radius = parser.Results.Radius;
    amount = parser.Results.Amount;
    threshold = parser.Results.Threshold;

    % Empty volumes require no processing.
    if isempty(inputVolume)
        outputVolume = inputVolume;
        return
    end

    inputClass = class(inputVolume);

    % Perform calculations in floating point. Preserve single precision
    % when the input is single to reduce memory usage for large volumes.
    if isa(inputVolume, 'single')
        workVolume = inputVolume;
    else
        workVolume = double(inputVolume);
    end

    validMask = isfinite(workVolume);

    % Nothing can be sharpened if the volume contains no finite voxels.
    if ~any(validMask(:))
        outputVolume = inputVolume;
        return
    end

    finiteValues = workVolume(validMask);
    inputMin = min(finiteValues);
    inputMax = max(finiteValues);
    dynamicRange = inputMax - inputMin;

    if all(validMask(:))
        % Fast path when no NaN or Inf values are present.
        blurredVolume = imgaussfilt3(workVolume, radius, ...
            'Padding', 'replicate');
    else
        % NaN-aware normalized Gaussian convolution.
        %
        % Gaussian(input .* mask) / Gaussian(mask)
        %
        % This ignores invalid voxels instead of treating them as zero.
        filledVolume = workVolume;
        filledVolume(~validMask) = 0;

        blurredVolume = imgaussfilt3(filledVolume, radius, ...
            'Padding', 'replicate');

        validWeights = cast(validMask, class(workVolume));

        weightVolume = imgaussfilt3(validWeights, radius, ...
            'Padding', 'replicate');

        hasWeight = weightVolume > 0;

        blurredVolume(hasWeight) = ...
            blurredVolume(hasWeight) ./ weightVolume(hasWeight);
    end

    % High-frequency component used for unsharp masking.
    detailVolume = workVolume - blurredVolume;

    if threshold > 0 && dynamicRange > 0
        thresholdValue = threshold * dynamicRange;
        sharpenMask = validMask & ...
            abs(detailVolume) >= thresholdValue;
    else
        sharpenMask = validMask;
    end

    sharpenedVolume = workVolume;

    % Modify only voxels selected for sharpening.
    sharpenedValues = workVolume(sharpenMask) + ...
        amount .* detailVolume(sharpenMask);

    % Prevent sharpening overshoot from expanding the original finite
    % dynamic range. Do not rescale the volume.
    sharpenedValues = max(sharpenedValues, inputMin);
    sharpenedValues = min(sharpenedValues, inputMax);

    sharpenedVolume(sharpenMask) = sharpenedValues;

    % Restore the original data type.
    outputVolume = cast(sharpenedVolume, inputClass);

    % Preserve NaN and Inf values exactly where they occurred.
    outputVolume(~validMask) = inputVolume(~validMask);
end


function tf = isValidRadius(value)

    tf = isnumeric(value) && isreal(value) && ...
        (isscalar(value) || numel(value) == 3) && ...
        all(isfinite(value(:))) && all(value(:) > 0);
end


function tf = isValidAmount(value)

    tf = isnumeric(value) && isreal(value) && isscalar(value) && ...
        isfinite(value) && value >= 0;
end


function tf = isValidThreshold(value)

    tf = isnumeric(value) && isreal(value) && isscalar(value) && ...
        isfinite(value) && value >= 0 && value <= 1;
end