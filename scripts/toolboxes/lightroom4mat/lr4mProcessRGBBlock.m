function output = lr4mProcessRGBBlock(input, parameters, filterDimensions)
%lr4mProcessRGBBlock - Apply color and luminance processing to an RGB block
%   OUTPUT = lr4mProcessRGBBlock(INPUT,PARAMETERS,DIMENSIONS) expects a
%   normalized RGB block with its three-channel axis after all spatial
%   dimensions.

input = lr4mApplyDehaze(input, parameters.Dehaze / 10, ...
    filterDimensions, true);
colorDimension = numel(filterDimensions) + 1;
red = lr4mExtractChannel(input, colorDimension, 1);
green = lr4mExtractChannel(input, colorDimension, 2);
blue = lr4mExtractChannel(input, colorDimension, 3);

% White balance and luminance replacement operate in linear light so equal
% channel gains correspond to equal changes in scene energy.
red = lr4mSrgbToLinear(red);
green = lr4mSrgbToLinear(green);
blue = lr4mSrgbToLinear(blue);
[red, green, blue] = applyWhiteBalance(red, green, blue, ...
    parameters.Warmth / 10, parameters.Tint / 10);

originalLuminance = lr4mRgbLuminance(red, green, blue);
adjustedLuminance = lr4mAdjustLuminance(originalLuminance, parameters, ...
    filterDimensions);
[red, green, blue] = replaceLuminance(red, green, blue, ...
    originalLuminance, adjustedLuminance);

red = lr4mLinearToSrgb(lr4mClamp01(red));
green = lr4mLinearToSrgb(lr4mClamp01(green));
blue = lr4mLinearToSrgb(lr4mClamp01(blue));
[red, green, blue] = applyColorfulness(red, green, blue, parameters);

output = zeros(size(input));
output = lr4mAssignChannel(output, colorDimension, 1, lr4mClamp01(red));
output = lr4mAssignChannel(output, colorDimension, 2, lr4mClamp01(green));
output = lr4mAssignChannel(output, colorDimension, 3, lr4mClamp01(blue));
end

function [red, green, blue] = applyWhiteBalance(red, green, blue, ...
        warmth, tint)
%applyWhiteBalance - Apply luminance-neutral temperature and tint gains
rawGains = exp([0.45 * warmth + 0.18 * tint, ...
    -0.35 * tint, -0.45 * warmth + 0.18 * tint]);

% Normalizing by the Rec. 709 weighted gain prevents a neutral patch from
% becoming globally brighter merely because its white balance changed.
normalizer = 0.2126 * rawGains(1) + 0.7152 * rawGains(2) + ...
    0.0722 * rawGains(3);
gains = rawGains ./ normalizer;
red = red .* gains(1);
green = green .* gains(2);
blue = blue .* gains(3);
end

function [red, green, blue] = replaceLuminance(red, green, blue, ...
        originalLuminance, adjustedLuminance)
%replaceLuminance - Scale RGB together to preserve channel relationships
nearBlack = 1e-7;
scale = adjustedLuminance ./ max(originalLuminance, nearBlack);
red = red .* scale;
green = green .* scale;
blue = blue .* scale;

% Pure black has no chromatic ratio to preserve. Assigning the requested
% luminance equally avoids division artifacts and remains neutral.
blackMask = originalLuminance <= nearBlack;
red(blackMask) = adjustedLuminance(blackMask);
green(blackMask) = adjustedLuminance(blackMask);
blue(blackMask) = adjustedLuminance(blackMask);

[red, green, blue] = compressGamut(red, green, blue);
end

function [red, green, blue] = applyColorfulness(red, green, blue, parameters)
%applyColorfulness - Apply hue-preserving saturation and vibrance scaling
maximumChannel = max(max(red, green), blue);
minimumChannel = min(min(red, green), blue);
saturation = (maximumChannel - minimumChannel) ./ max(maximumChannel, eps);

saturationAmount = parameters.Saturation / 10;
if saturationAmount >= 0
    targetSaturation = min(1, saturation .* (1 + saturationAmount));
else
    targetSaturation = saturation .* (1 + saturationAmount);
end

% Vibrance weights low-saturation pixels most strongly. Highly saturated
% colors therefore approach the gamut boundary more gradually.
vibranceAmount = min(max(parameters.Vibrance / 10, -1), 1);
targetSaturation = targetSaturation .* ...
    (1 + 0.90 * vibranceAmount .* (1 - targetSaturation));
targetSaturation = lr4mClamp01(targetSaturation);

chromaScale = targetSaturation ./ max(saturation, eps);
chromaScale(saturation <= eps) = 0;
luminance = lr4mRgbLuminance(red, green, blue);
red = luminance + chromaScale .* (red - luminance);
green = luminance + chromaScale .* (green - luminance);
blue = luminance + chromaScale .* (blue - luminance);

% First translate negative channels back into gamut, then scale only pixels
% whose maximum still exceeds one. Both operations preserve hue direction.
minimumChannel = min(min(red, green), blue);
offset = min(minimumChannel, 0);
red = red - offset;
green = green - offset;
blue = blue - offset;
[red, green, blue] = compressGamut(red, green, blue);
end

function [red, green, blue] = compressGamut(red, green, blue)
%compressGamut - Scale over-range RGB triplets without clipping channels
maximumChannel = max(max(red, green), blue);
gamutScale = max(maximumChannel, 1);
red = red ./ gamutScale;
green = green ./ gamutScale;
blue = blue ./ gamutScale;
end

