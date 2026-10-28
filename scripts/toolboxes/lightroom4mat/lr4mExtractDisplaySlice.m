function slice = lr4mExtractDisplaySlice(input, frameDimensions, ...
        frameIndex, isRGB, colorDimension)
%lr4mExtractDisplaySlice - Extract one row-by-column preview plane
%   SLICE = lr4mExtractDisplaySlice(INPUT,FRAMEDIMS,INDEX,isRGB,COLORDIM)
%   converts a flattened N-D frame index into subscripts and returns either
%   a two-dimensional grayscale plane or a row-by-column-by-three RGB
%   image.

subscripts = repmat({':'}, 1, ndims(input));
if ~isempty(frameDimensions)
    frameSize = size(input);
    frameSize = frameSize(frameDimensions);
    frameSubscripts = cell(1, numel(frameDimensions));

    if isscalar(frameDimensions)
        frameSubscripts{1} = frameIndex;
    else
        [frameSubscripts{:}] = ind2sub(frameSize, frameIndex);
    end
    for index = 1:numel(frameDimensions)
        subscripts{frameDimensions(index)} = frameSubscripts{index};
    end
end
slice = input(subscripts{:});

if isRGB
    % Move an alternate color axis into conventional third position after
    % all frame dimensions have been reduced to singleton axes.
    order = [1 2 colorDimension setdiff(3:ndims(input), ...
        colorDimension, "stable")];
    slice = permute(slice, order);
    slice = reshape(slice, size(input, 1), size(input, 2), 3);
else
    slice = reshape(slice, size(input, 1), size(input, 2));
end
end
