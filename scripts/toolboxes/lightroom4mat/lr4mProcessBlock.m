function output = lr4mProcessBlock(input, parameters, isRGB, ...
        filterDimensions)
%lr4mProcessBlock - Normalize, adjust, and restore one processing block
%   OUTPUT = lr4mProcessBlock(INPUT,PARAMETERS,isRGB,DIMENSIONS) applies a
%   grayscale or RGB pipeline while preserving INPUT's class and observed
%   numeric range.

inputDouble = double(input);
lowerBound = min(inputDouble, [], "all");
upperBound = max(inputDouble, [], "all");

% A constant block has no usable intensity range. Leaving it unchanged is
% deterministic and avoids division by zero during normalization.
if lowerBound == upperBound
    output = input;
    return
end

observedRange = upperBound - lowerBound;
normalized = (inputDouble - lowerBound) ./ observedRange;

if isRGB
    adjusted = lr4mProcessRGBBlock(normalized, parameters, ...
        filterDimensions);
else
    normalized = lr4mApplyDehaze(normalized, parameters.Dehaze / 10, ...
        filterDimensions, false);
    luminance = lr4mSrgbToLinear(normalized);
    luminance = lr4mAdjustLuminance(luminance, parameters, ...
        filterDimensions);
    adjusted = lr4mLinearToSrgb(luminance);
end

% Clamping before range restoration guarantees that no adjustment expands
% a block beyond its original observed endpoints.
adjusted = lr4mClamp01(adjusted);
restored = lowerBound + adjusted .* observedRange;
if isinteger(input)
    restored = round(restored);
end
output = cast(restored, "like", input);
end
