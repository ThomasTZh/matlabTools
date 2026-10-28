function names = lr4mAdjustmentNames()
%lr4mAdjustmentNames - Return canonical controls in GUI and command order
%   NAMES = lr4mAdjustmentNames() returns the single ordering contract used
%   for parameter structs, GUI rows, and generated command arguments.

% Keep aliases such as Warms out of this list: aliases are accepted only at
% the public boundary and are canonicalized before processing.
names = ["Exposure" "Contrast" "Highlights" "Shadows" "Whites" ...
    "Blacks" "Saturation" "Warmth" "Tint" "Vibrance" ...
    "Texture" "Sharpness" "Clarity" "Dehaze"];
end
