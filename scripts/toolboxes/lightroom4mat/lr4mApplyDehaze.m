function output = lr4mApplyDehaze(input, amount, filterDimensions, isRGB)
%lr4mApplyDehaze - Apply a local dark-channel haze model
%   OUTPUT = lr4mApplyDehaze(INPUT,AMOUNT,DIMENSIONS,isRGB) estimates
%   atmospheric light and local transmission from normalized image data.

if amount == 0
    output = input;
    return
end

if isRGB
    output = applyRGBModel(input, amount, filterDimensions);
else
    output = applyGrayscaleModel(input, amount, filterDimensions);
end
end

function output = applyRGBModel(input, amount, filterDimensions)
%applyRGBModel - Apply dehaze while retaining channel relationships
colorDimension = numel(filterDimensions) + 1;
red = lr4mExtractChannel(input, colorDimension, 1);
green = lr4mExtractChannel(input, colorDimension, 2);
blue = lr4mExtractChannel(input, colorDimension, 3);

darkChannel = min(min(red, green), blue);
localDark = localMinimumND(darkChannel, filterDimensions);
sampleIndices = brightestDarkChannelSamples(localDark);
airlight = [mean(red(sampleIndices)) mean(green(sampleIndices)) ...
    mean(blue(sampleIndices))];
airlight = max(airlight, 0.05);

if amount > 0
    airlightLuminance = lr4mRgbLuminance(airlight(1), airlight(2), ...
        airlight(3));
    transmission = 1 - 0.82 * amount .* localDark ./ ...
        max(airlightLuminance, 0.05);
    transmission = max(transmission, 0.22);
    red = (red - airlight(1)) ./ transmission + airlight(1);
    green = (green - airlight(2)) ./ transmission + airlight(2);
    blue = (blue - airlight(3)) ./ transmission + airlight(3);
else
    % Negative dehaze synthesizes atmospheric veil rather than attempting
    % an unstable inverse of the positive transmission equation.
    hazeWeight = -amount .* (0.20 + 0.45 .* ...
        lr4mSmoothStep(localDark, 0.05, 0.85));
    red = red + hazeWeight .* (airlight(1) - red);
    green = green + hazeWeight .* (airlight(2) - green);
    blue = blue + hazeWeight .* (airlight(3) - blue);
end

output = zeros(size(input));
output = lr4mAssignChannel(output, colorDimension, 1, lr4mClamp01(red));
output = lr4mAssignChannel(output, colorDimension, 2, lr4mClamp01(green));
output = lr4mAssignChannel(output, colorDimension, 3, lr4mClamp01(blue));
end

function output = applyGrayscaleModel(input, amount, filterDimensions)
%applyGrayscaleModel - Apply the transmission model to grayscale data
localDark = localMinimumND(input, filterDimensions);
sampleIndices = brightestDarkChannelSamples(localDark);
airlight = max(mean(input(sampleIndices)), 0.05);

if amount > 0
    transmission = 1 - 0.82 * amount .* localDark ./ airlight;
    transmission = max(transmission, 0.22);
    output = (input - airlight) ./ transmission + airlight;
else
    hazeWeight = -amount .* (0.20 + 0.45 .* ...
        lr4mSmoothStep(localDark, 0.05, 0.85));
    output = input + hazeWeight .* (airlight - input);
end
output = lr4mClamp01(output);
end

function indices = brightestDarkChannelSamples(localDark)
%brightestDarkChannelSamples - Select candidates for atmospheric light
[~, order] = sort(localDark(:), "descend");
sampleCount = max(1, ceil(0.005 * numel(localDark)));
indices = order(1:sampleCount);
end

function output = localMinimumND(input, dimensions)
%localMinimumND - Calculate a capped local minimum on selected axes
output = input;
for dimension = dimensions
    dimensionLength = size(output, dimension);
    radius = min(7, floor((dimensionLength - 1) / 2));
    if radius < 1
        continue
    end
    output = movmin(output, 2 * radius + 1, dimension, ...
        Endpoints="shrink");
end
end

