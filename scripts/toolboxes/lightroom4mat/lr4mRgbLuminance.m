function output = lr4mRgbLuminance(red, green, blue)
%lr4mRgbLuminance - Calculate Rec. 709 linear-light luminance
%   OUTPUT = lr4mRgbLuminance(RED,GREEN,BLUE) combines normalized linear
%   channels using the Rec. 709 luminance coefficients.

output = 0.2126 .* red + 0.7152 .* green + 0.0722 .* blue;
end
