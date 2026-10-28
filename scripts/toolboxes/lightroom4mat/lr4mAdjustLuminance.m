function luminance = lr4mAdjustLuminance(luminance, parameters, ...
        filterDimensions)
%lr4mAdjustLuminance - Apply tone and scale-separated detail controls
%   LUMINANCE = lr4mAdjustLuminance(LUMINANCE,PARAMETERS,DIMENSIONS)
%   processes linear-light luminance. Tone curves are evaluated in an
%   sRGB-like encoding, matching the perceptual response of photo editors.

% Exposure spans four stops in either direction. The wider range makes the
% full -10 to +10 control useful without changing the one-decimal API.
exposure = parameters.Exposure / 10;
luminance = lr4mClamp01(luminance .* 2 .^ (4 * exposure));
tone = lr4mLinearToSrgb(luminance);

contrast = parameters.Contrast / 10;
if contrast ~= 0
    % A symmetric power-ratio curve fixes black, middle gray, and white.
    % This avoids the endpoint clipping caused by a simple centered slope.
    exponent = 2 .^ (1.6 * contrast);
    raised = tone .^ exponent;
    inverseRaised = (1 - tone) .^ exponent;
    tone = raised ./ max(raised + inverseRaised, eps);
end

highlights = parameters.Highlights / 10;
if highlights ~= 0
    % The smooth mask protects midtones while an endpoint-anchored curve
    % compresses or expands only the upper tonal region.
    highlightExponent = 2 .^ (0.85 * highlights);
    highlightTarget = 1 - (1 - tone) .^ highlightExponent;
    highlightMask = lr4mSmoothStep(tone, 0.50, 0.90);
    tone = tone + highlightMask .* (highlightTarget - tone);
end

shadows = parameters.Shadows / 10;
if shadows ~= 0
    shadowExponent = 2 .^ (-0.85 * shadows);
    shadowTarget = tone .^ shadowExponent;
    shadowMask = 1 - lr4mSmoothStep(tone, 0.10, 0.50);
    tone = tone + shadowMask .* (shadowTarget - tone);
end

whites = parameters.Whites / 10;
if whites ~= 0
    tone = adjustWhitePoint(tone, whites);
end

blacks = parameters.Blacks / 10;
if blacks ~= 0
    tone = adjustBlackPoint(tone, blacks);
end

clarity = parameters.Clarity / 10;
if clarity ~= 0
    middleBase = lr4mGaussianFilterND(tone, 4, filterDimensions);
    midtoneMask = (4 .* tone .* (1 - tone)) .^ 1.2;
    tone = tone + 0.65 * clarity .* ...
        (tone - middleBase) .* midtoneMask;
    tone = lr4mClamp01(tone);
end

texture = parameters.Texture / 10;
if texture ~= 0
    % A difference of Gaussian scales isolates texture-sized detail while
    % rejecting both pixel noise and broad illumination gradients.
    fineBase = lr4mGaussianFilterND(tone, 0.8, filterDimensions);
    coarseBase = lr4mGaussianFilterND(tone, 2.4, filterDimensions);
    tone = tone + 1.25 * texture .* (fineBase - coarseBase);
    tone = lr4mClamp01(tone);
end

sharpness = parameters.Sharpness / 10;
if sharpness ~= 0
    sharpBase = lr4mGaussianFilterND(tone, 0.8, filterDimensions);
    detail = tone - sharpBase;
    if sharpness > 0
        % Suppress extremely small residuals when sharpening so smooth
        % regions do not gain visible noise. Negative values intentionally
        % retain all residuals to behave as stable softening.
        edgeMask = lr4mSmoothStep(abs(detail), 0.002, 0.035);
        detail = detail .* edgeMask;
        amount = 1.65 * sharpness;
    else
        amount = 1.25 * sharpness;
    end
    tone = lr4mClamp01(tone + amount .* detail);
end

luminance = lr4mSrgbToLinear(tone);
end

function output = adjustWhitePoint(input, amount)
%adjustWhitePoint - Move the upper clipping point around a fixed pivot
pivot = 0.65;
output = input;
upperMask = input > pivot;

if amount > 0
    % Lowering the input clipping point maps more bright samples to one.
    clippingPoint = 1 - 0.18 * amount;
    scale = (1 - pivot) / (clippingPoint - pivot);
else
    outputWhite = 1 - 0.18 * (-amount);
    scale = (outputWhite - pivot) / (1 - pivot);
end
output(upperMask) = pivot + (input(upperMask) - pivot) .* scale;
output = lr4mClamp01(output);
end

function output = adjustBlackPoint(input, amount)
%adjustBlackPoint - Move the lower clipping point around a fixed pivot
pivot = 0.35;
output = input;
lowerMask = input < pivot;

if amount < 0
    % Raising the input black point maps more dark samples to zero.
    clippingPoint = 0.18 * (-amount);
    scale = pivot / (pivot - clippingPoint);
    output(lowerMask) = (input(lowerMask) - clippingPoint) .* scale;
else
    outputBlack = 0.18 * amount;
    scale = (pivot - outputBlack) / pivot;
    output(lowerMask) = outputBlack + input(lowerMask) .* scale;
end
output = lr4mClamp01(output);
end
