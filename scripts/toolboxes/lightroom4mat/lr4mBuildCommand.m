function command = lr4mBuildCommand(variableName, dimensions, parameters, ...
        colorMode, colorDimension)
%lr4mBuildCommand - Create a canonical non-GUI function call
%   COMMAND = lr4mBuildCommand(NAME,DIMENSIONS,PARAMETERS,MODE,COLORDIM)
%   serializes active adjustments and nondefault color metadata into a
%   reproducible lightroom4mat call.

names = lr4mAdjustmentNames();

% The fixed upper bound covers the input, dimensions, every adjustment,
% both color metadata arguments, and GUI=false. Preallocation also makes
% the final truncation explicit rather than growing a string array in-loop.
argumentsList = strings(numel(names) + 5, 1);
argumentCount = 2;
argumentsList(1) = variableName;
argumentsList(2) = formatDimensions(dimensions);

% Iterating in the shared canonical order makes copied commands stable and
% easy to compare even when callers supplied name-values in another order.
for index = 1:numel(names)
    name = names(index);
    value = parameters.(name);
    if value ~= 0
        argumentCount = argumentCount + 1;
        argumentsList(argumentCount) = string(sprintf('"%s", %.1f', ...
            name, value));
    end
end

% Defaults are omitted to keep commands concise. GUI=false is always
% emitted because replaying a copied command must process data rather than
% reopen the modal editor.
if colorMode ~= "auto"
    argumentCount = argumentCount + 1;
    argumentsList(argumentCount) = string(sprintf( ...
        '"ColorMode", "%s"', colorMode));
end
if colorDimension ~= 3
    argumentCount = argumentCount + 1;
    argumentsList(argumentCount) = string(sprintf( ...
        '"ColorDimension", %d', colorDimension));
end
argumentCount = argumentCount + 1;
argumentsList(argumentCount) = '"GUI", false';
argumentsList = argumentsList(1:argumentCount);
command = "adjustedImage = lightroom4mat(" + ...
    strjoin(argumentsList, ", ") + ");";
end

function output = formatDimensions(dimensions)
%formatDimensions - Format the original dimension selector for a command
%   Preserve numeric selections exactly, while representing either accepted
%   spelling of all dimensions with one canonical double-quoted value.
if isempty(dimensions)
    output = "[]";
elseif ischar(dimensions) || isstring(dimensions)
    output = '"all"';
else
    output = string(mat2str(double(dimensions)));
end
end
