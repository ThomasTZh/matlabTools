function output = lr4mGaussianFilterND(input, targetSigma, dimensions)
%lr4mGaussianFilterND - Filter selected axes with separable Gaussians
%   OUTPUT = lr4mGaussianFilterND(INPUT,SIGMA,DIMENSIONS) applies symmetric
%   one-dimensional kernels along each selected axis. Small axes cap SIGMA
%   so the kernel remains meaningful for thin volumes and short rows.

output = input;
for dimension = dimensions
    dimensionLength = size(output, dimension);
    maximumSigma = max((dimensionLength - 1) / 6, 0);
    sigma = min(targetSigma, maximumSigma);
    if sigma < 0.15
        continue
    end

    radius = max(1, ceil(3 * sigma));
    coordinates = -radius:radius;
    kernel = exp(-(coordinates .^ 2) ./ (2 * sigma ^ 2));
    kernel = kernel ./ sum(kernel);

    % Reshaping the vector selects exactly one N-D axis for imfilter and
    % prevents accidental smoothing across color or independent blocks.
    kernelShape = ones(1, max(ndims(output), dimension));
    kernelShape(dimension) = numel(kernel);
    kernel = reshape(kernel, kernelShape);
    output = imfilter(output, kernel, "symmetric", "conv", "same");
end
end
