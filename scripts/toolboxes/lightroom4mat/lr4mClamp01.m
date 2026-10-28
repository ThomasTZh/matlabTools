function output = lr4mClamp01(input)
%lr4mClamp01 - Clamp numeric data to the closed unit interval
%   OUTPUT = lr4mClamp01(INPUT) clips values below zero and above one while
%   preserving the shape of INPUT.

output = min(max(input, 0), 1);
end
