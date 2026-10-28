function output = lr4mProcessArray(input, processingDimensions, ...
        parameters, isRGB, colorDimension)
%lr4mProcessArray - Apply adjustments to independent array blocks
%   OUTPUT = lr4mProcessArray(INPUT,DIMENSIONS,PARAMETERS,isRGB,COLORDIM)
%   jointly processes DIMENSIONS and enumerates every remaining axis as
%   independent blocks. For RGB data, COLORDIM joins each block but is not
%   included in the spatial-filter dimension list.

% The exact identity path is important for integer data and avoids a
% normalize/cast round trip when the editor only builds a command.
if ~hasActiveAdjustments(parameters)
    output = input;
    return
end

numberOfDimensions = ndims(input);
inputSize = size(input);
inputSize(end + 1:numberOfDimensions) = 1;

if isRGB
    groupDimensions = [processingDimensions colorDimension];
else
    groupDimensions = processingDimensions;
end
independentDimensions = setdiff(1:numberOfDimensions, ...
    groupDimensions, "stable");

% Permuting the jointly processed axes to the front turns arbitrary N-D
% block enumeration into a compact column loop. ipermute later restores
% both the caller's dimension order and singleton dimensions.
permutation = [groupDimensions independentDimensions];
groupSize = inputSize(groupDimensions);
independentSize = inputSize(independentDimensions);
numberOfBlocks = max(1, prod(independentSize));

permuted = permute(input, permutation);
columns = reshape(permuted, prod(groupSize), numberOfBlocks);
resultColumns = columns;

blockShape = groupSize;
if isscalar(blockShape)
    blockShape = [blockShape 1];
end
filterDimensions = 1:numel(processingDimensions);

for blockIndex = 1:numberOfBlocks
    block = reshape(columns(:, blockIndex), blockShape);
    result = lr4mProcessBlock(block, parameters, isRGB, ...
        filterDimensions);
    resultColumns(:, blockIndex) = result(:);
end

permutedSize = [groupSize independentSize];
if isscalar(permutedSize)
    permutedSize = [permutedSize 1];
end
resultPermuted = reshape(resultColumns, permutedSize);
output = ipermute(resultPermuted, permutation);
end

function active = hasActiveAdjustments(parameters)
%hasActiveAdjustments - Test whether any canonical adjustment is nonzero
active = any(struct2array(parameters) ~= 0);
end
