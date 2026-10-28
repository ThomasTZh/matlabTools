function varargout = lightroom4mat(inputImage, dimensions, options)
%lightroom4mat - Apply photo-editor adjustments to numeric arrays
%   B = lightroom4mat(A,DIMENSIONS) jointly processes the selected
%   dimensions. Use [], "all", or 'all' to select every dimension.
%   Unselected dimensions enumerate independent processing blocks.
%
%   B = lightroom4mat(...,Name=VALUE) specifies adjustments from -10 to
%   10. Values are rounded to the nearest 0.1. Supported names are
%   Exposure, Contrast, Highlights, Shadows, Whites, Blacks, Saturation,
%   Warmth, Tint, Vibrance, Texture, Sharpness, Clarity, and Dehaze.
%   Warms is an alias for Warmth.
%
%   [B,COMMAND] = lightroom4mat(...) also returns a canonical non-GUI
%   command containing only active adjustments.
%
%   COMMAND = lightroom4mat(...,GUI=true) opens a modal editor. Done
%   returns only a canonical command with GUI=false; it does not process
%   the complete array. Cancel or window-close returns "" and issues
%   warning lightroom4mat:Cancelled. GUI mode accepts at most one output.
%
%   B = lightroom4mat(...,ColorMode=MODE,ColorDimension=DIM) controls RGB
%   interpretation. MODE is "auto" (default), "rgb", or "grayscale".
%   Auto recognizes an RGB axis of length three at DIM, which defaults to
%   dimension 3. Dimensions 1 and 2 are the displayed image axes.
%
%   Each block is normalized to [0,1], adjusted, clamped to its observed
%   range, and cast back to its original class. RGB tone and detail use
%   Rec. 709 linear-light luminance. Constant blocks remain unchanged.
%   All-zero adjustments bypass processing and are bit-identical.
%
%   Highlights and Shadows use endpoint-anchored regional tone curves.
%   Whites and Blacks act on their respective clipping regions. Texture,
%   Clarity, and Sharpness operate at distinct spatial scales. Dehaze uses
%   a local dark-channel transmission approximation.
%
%   Example: Edit an RGB image without opening the GUI
%       a = imread("peppers.png");
%       b = lightroom4mat(a,[1 2],Exposure=1.5,Vibrance=2);
%       imageshow(b)
%
%   See also imageshow, viewer2d, imfilter, movmin
%
%   Note: lightroom4mat is deterministic and photo-editor-inspired. It
%   does not reproduce proprietary Adobe or Google implementations

arguments
    inputImage {mustBeNumeric, mustBeReal, mustBeFinite, mustBeNonempty}
    dimensions
    options.Exposure {mustBeAdjustment} = 0
    options.Contrast {mustBeAdjustment} = 0
    options.Highlights {mustBeAdjustment} = 0
    options.Shadows {mustBeAdjustment} = 0
    options.Whites {mustBeAdjustment} = 0
    options.Blacks {mustBeAdjustment} = 0
    options.Saturation {mustBeAdjustment} = 0
    options.Warmth {mustBeAdjustment} = 0
    options.Warms {mustBeAdjustment} = 0
    options.Tint {mustBeAdjustment} = 0
    options.Vibrance {mustBeAdjustment} = 0
    options.Texture {mustBeAdjustment} = 0
    options.Sharpness {mustBeAdjustment} = 0
    options.Clarity {mustBeAdjustment} = 0
    options.Dehaze {mustBeAdjustment} = 0
    options.GUI = false
    options.ColorMode = "auto"
    options.ColorDimension = 3
end

inputVariableName = string(inputname(1));
if strlength(inputVariableName) == 0
    % Expressions and literals have no caller-side variable name. Use a
    % visible placeholder so generated commands remain easy to edit.
    inputVariableName = "inputImage";
end

% Consolidate cross-option validation before entering either execution
% path. Keeping this policy in one helper prevents GUI and batch behavior
% from drifting as new controls are introduced.
request = lr4mPrepareRequest(inputImage, dimensions, options);

if request.GUI
    if nargout > 1
        error("lightroom4mat:TooManyGUIOutputs", ...
            "GUI mode returns one command string.");
    end
    guiCommand = lr4mRunEditor(inputImage, dimensions, request, ...
        inputVariableName);
    if nargout == 1
        varargout{1} = guiCommand;
    end
    return
end

% Batch mode performs the exact N-D pipeline. GUI previews deliberately use
% only the visible plane and therefore never flow through this branch.
adjustedImage = lr4mProcessArray(inputImage, ...
    request.SpatialDimensions, request.EffectiveParameters, ...
    request.IsRGB, request.ColorDimension);
command = lr4mBuildCommand(inputVariableName, dimensions, ...
    request.Parameters, request.ColorMode, request.ColorDimension);
if nargout > 2
    error("lightroom4mat:TooManyOutputs", ...
        "Non-GUI mode returns at most two outputs.");
end
if nargout >= 1
    varargout{1} = adjustedImage;
end
if nargout >= 2
    varargout{2} = command;
end
end

function mustBeAdjustment(value)
%mustBeAdjustment - Validate the public adjustment scale
%   This validator remains local so the arguments block exposes no helper
%   function as part of the folder-level API.
if ~(isnumeric(value) && isscalar(value) && isreal(value) && ...
        isfinite(value) && value >= -10 && value <= 10)
    error("lightroom4mat:InvalidAdjustment", ...
        "Adjustment values must be finite real numeric scalars from -10 to 10.");
end
end
