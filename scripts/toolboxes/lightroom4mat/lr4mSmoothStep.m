function output = lr4mSmoothStep(input, lowerBound, upperBound)
%lr4mSmoothStep - Create a cubic mask with zero endpoint derivatives
%   OUTPUT = lr4mSmoothStep(INPUT,LOWER,UPPER) maps values below LOWER to
%   zero, values above UPPER to one, and blends smoothly between them.

position = lr4mClamp01((input - lowerBound) ./ ...
    (upperBound - lowerBound));
output = position .^ 2 .* (3 - 2 .* position);
end
