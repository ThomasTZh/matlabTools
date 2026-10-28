function output = lr4mSrgbToLinear(input)
%lr4mSrgbToLinear - Decode normalized sRGB-like values to linear light
%   OUTPUT = lr4mSrgbToLinear(INPUT) applies the standard piecewise sRGB
%   electro-optical transfer function to normalized data.

output = input ./ 12.92;
nonlinearMask = input > 0.04045;
output(nonlinearMask) = ((input(nonlinearMask) + 0.055) ./ 1.055) ...
    .^ 2.4;
end
