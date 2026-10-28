function request = lr4mPrepareRequest(inputImage, dimensions, options)
%lr4mPrepareRequest - Validate and canonicalize a processing request
%   REQUEST = lr4mPrepareRequest(A,DIMENSIONS,OPTIONS) resolves dimension,
%   color, GUI, and adjustment options into one immutable request struct.
%
%   This internal boundary owns validation that depends on more than one
%   option. The public arguments block still performs type-level checks.

if issparse(inputImage)
    error("lightroom4mat:SparseInput", ...
        "INPUTIMAGE must be a full numeric array.");
end

processingDimensions = normalizeDimensions(dimensions, ndims(inputImage));
colorMode = normalizeColorMode(options.ColorMode);
colorDimension = normalizeColorDimension(options.ColorDimension);
isRGB = resolveColorMode(inputImage, colorMode, colorDimension);

% The color axis participates in a jointly normalized RGB block but must
% never be spatially filtered. Removing it here gives every downstream
% filter the same, unambiguous list of spatial axes.
if isRGB
    spatialDimensions = setdiff(processingDimensions, colorDimension, ...
        "stable");
    if isempty(spatialDimensions)
        error("lightroom4mat:NoProcessingDimensions", ...
            "DIMENSIONS must contain at least one non-color dimension for RGB data.");
    end
else
    spatialDimensions = processingDimensions;
end

parameters = canonicalParameters(options);
effectiveParameters = parameters;
if ~isRGB
    % Retain the requested values for command generation while disabling
    % controls whose definitions require chroma or separate RGB channels.
    effectiveParameters.Saturation = 0;
    effectiveParameters.Vibrance = 0;
    effectiveParameters.Warmth = 0;
    effectiveParameters.Tint = 0;
end

request = struct( ...
    ProcessingDimensions=processingDimensions, ...
    SpatialDimensions=spatialDimensions, ...
    GUI=normalizeGUI(options.GUI), ...
    ColorMode=colorMode, ...
    ColorDimension=colorDimension, ...
    IsRGB=isRGB, ...
    Parameters=parameters, ...
    EffectiveParameters=effectiveParameters);
end

function dimensions = normalizeDimensions(value, numberOfDimensions)
%normalizeDimensions - Normalize the processing dimension selection
if isempty(value)
    dimensions = 1:numberOfDimensions;
    return
end

if ischar(value) || (isstring(value) && isscalar(value))
    if strcmpi(string(value), "all")
        dimensions = 1:numberOfDimensions;
        return
    end
    error("lightroom4mat:InvalidDimensions", ...
        "Text DIMENSIONS must be 'all' or ""all"".");
end

isValidVector = isnumeric(value) && isvector(value) && isreal(value) && ...
    all(isfinite(value), "all") && all(value == fix(value), "all") && ...
    all(value >= 1, "all") && all(value <= numberOfDimensions, "all");
if ~isValidVector
    error("lightroom4mat:InvalidDimensions", ...
        "DIMENSIONS must contain valid positive integer dimension indices.");
end

dimensions = double(value(:).');
if numel(unique(dimensions)) ~= numel(dimensions)
    error("lightroom4mat:DuplicateDimensions", ...
        "DIMENSIONS must not contain duplicate indices.");
end

% Sorting produces a deterministic memory layout regardless of the order
% in which a caller lists the jointly processed dimensions.
dimensions = sort(dimensions);
end

function enabled = normalizeGUI(value)
%normalizeGUI - Normalize supported GUI flag forms
if islogical(value) && isscalar(value)
    enabled = value;
elseif isnumeric(value) && isscalar(value) && isreal(value) && ...
        isfinite(value) && any(value == [0 1])
    enabled = logical(value);
elseif (ischar(value) || (isstring(value) && isscalar(value))) && ...
        any(strcmpi(string(value), ["on" "off"]))
    enabled = strcmpi(string(value), "on");
else
    error("lightroom4mat:InvalidGUI", ...
        "GUI must be true, false, 1, 0, 'on', or 'off'.");
end
end

function mode = normalizeColorMode(value)
%normalizeColorMode - Normalize the color interpretation mode
validModes = ["auto" "rgb" "grayscale"];
if ~(ischar(value) || (isstring(value) && isscalar(value)))
    error("lightroom4mat:InvalidColorMode", ...
        "ColorMode must be ""auto"", ""rgb"", or ""grayscale"".");
end

mode = lower(string(value));
if ~ismember(mode, validModes)
    error("lightroom4mat:InvalidColorMode", ...
        "ColorMode must be ""auto"", ""rgb"", or ""grayscale"".");
end
end

function dimension = normalizeColorDimension(value)
%normalizeColorDimension - Validate the RGB channel dimension
if ~(isnumeric(value) && isscalar(value) && isreal(value) && ...
        isfinite(value) && value == fix(value) && value >= 3)
    error("lightroom4mat:InvalidColorDimension", ...
        "ColorDimension must be an integer greater than or equal to 3.");
end
dimension = double(value);
end

function isRGB = resolveColorMode(inputImage, mode, colorDimension)
%resolveColorMode - Determine whether the input has an RGB channel axis
axisExists = colorDimension <= ndims(inputImage);
axisHasThreeChannels = axisExists && ...
    (size(inputImage, colorDimension) == 3);

switch mode
    case "auto"
        isRGB = axisHasThreeChannels;
    case "rgb"
        if ~axisHasThreeChannels
            error("lightroom4mat:InvalidRGBDimension", ...
                "ColorDimension must identify an existing axis of length 3.");
        end
        isRGB = true;
    otherwise
        % normalizeColorMode guarantees the only remaining case is
        % grayscale, including ambiguous three-plane volumes.
        isRGB = false;
end
end

function parameters = canonicalParameters(options)
%canonicalParameters - Resolve aliases into canonical adjustment names
warmth = lr4mQuantizeAdjustment(options.Warmth);
warms = lr4mQuantizeAdjustment(options.Warms);
if warmth ~= 0 && warms ~= 0 && warmth ~= warms
    error("lightroom4mat:ConflictingWarmth", ...
        "Warmth and Warms cannot specify conflicting nonzero values.");
end
if warmth == 0
    warmth = warms;
end

parameters = struct( ...
    Exposure=lr4mQuantizeAdjustment(options.Exposure), ...
    Contrast=lr4mQuantizeAdjustment(options.Contrast), ...
    Highlights=lr4mQuantizeAdjustment(options.Highlights), ...
    Shadows=lr4mQuantizeAdjustment(options.Shadows), ...
    Whites=lr4mQuantizeAdjustment(options.Whites), ...
    Blacks=lr4mQuantizeAdjustment(options.Blacks), ...
    Saturation=lr4mQuantizeAdjustment(options.Saturation), ...
    Warmth=warmth, ...
    Tint=lr4mQuantizeAdjustment(options.Tint), ...
    Vibrance=lr4mQuantizeAdjustment(options.Vibrance), ...
    Texture=lr4mQuantizeAdjustment(options.Texture), ...
    Sharpness=lr4mQuantizeAdjustment(options.Sharpness), ...
    Clarity=lr4mQuantizeAdjustment(options.Clarity), ...
    Dehaze=lr4mQuantizeAdjustment(options.Dehaze));
end
