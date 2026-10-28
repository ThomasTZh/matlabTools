function output = lr4mLinearToSrgb(input)
%lr4mLinearToSrgb - Encode linear-light data as normalized sRGB-like values
%   OUTPUT = lr4mLinearToSrgb(INPUT) applies the standard piecewise sRGB
%   opto-electrical transfer function and anchors exact range endpoints.

output = 12.92 .* input;
nonlinearMask = input > 0.0031308;
output(nonlinearMask) = 1.055 .* input(nonlinearMask) ...
    .^ (1 / 2.4) - 0.055;

% Exact endpoint assignment prevents transfer-function roundoff from
% weakening the intentional clipping produced by Whites and Blacks.
output(input <= 0) = 0;
output(input >= 1) = 1;
end
