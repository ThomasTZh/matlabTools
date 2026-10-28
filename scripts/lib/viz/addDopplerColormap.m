function colorMap = addDopplerColormap(figureHandle, positiveColor, ...
    negativeColor, zeroColor, numShades)
%ADDDOPPLERCOLORMAP Apply a Doppler-style diverging colormap to a figure.
%
% Description
%   ADDDOPPLERCOLORMAP applies a diverging colormap suitable for displaying
%   signed Doppler data. Negative values transition from blue to white,
%   while positive values transition from white to red. NaN image values
%   are displayed as black.
%
%   The colour limits are automatically made symmetric about zero using
%   the displayed data.
%
% Syntax
%   addDopplerColormap
%   addDopplerColormap(figureHandle)
%   addDopplerColormap(figureHandle, positiveColor, negativeColor)
%   addDopplerColormap(figureHandle, positiveColor, negativeColor, ...
%       zeroColor, numShades)
%   colorMap = addDopplerColormap(...)
%
% Input Arguments
%   figureHandle  - Target figure. Default is the current figure.
%   positiveColor - RGB colour for positive values. Default is [1 0 0].
%   negativeColor - RGB colour for negative values. Default is [0 0 1].
%   zeroColor     - RGB colour corresponding to zero. Default is [1 1 1].
%   numShades     - Number of colormap entries. Default is 256.
%
% Output Arguments
%   colorMap      - Generated numShades-by-3 RGB colormap.

    arguments
        figureHandle (1, 1) matlab.ui.Figure = gcf
        positiveColor (1, 3) double ...
            {mustBeInRange(positiveColor, 0, 1)} = [1 0 0]
        negativeColor (1, 3) double ...
            {mustBeInRange(negativeColor, 0, 1)} = [0 0 1]
        zeroColor (1, 3) double ...
            {mustBeInRange(zeroColor, 0, 1)} = [1 1 1]
        numShades (1, 1) double ...
            {mustBeInteger, mustBeGreaterThanOrEqual(numShades, 2)} = 256
    end

    % Generate the diverging colormap.
    numNegative = floor(numShades / 2);
    numPositive = numShades - numNegative;

    negativeMap = interpolateColor( ...
        negativeColor, zeroColor, numNegative);

    positiveMap = interpolateColor( ...
        zeroColor, positiveColor, numPositive);

    colorMap = [negativeMap; positiveMap];

    % Apply the colormap to the figure.
    colormap(figureHandle, colorMap);

    targetAxes = figureHandle.CurrentAxes;

    if isempty(targetAxes)
        return;
    end

    % FRAMEVIEWER3D uses "axis off", which also hides the axes
    % background. Turn the axes back on, but hide all ruler graphics
    % so that the visual appearance remains equivalent to "axis off".
    targetAxes.Visible = 'on';
    targetAxes.Color = [0 0 0];
    targetAxes.XColor = 'none';
    targetAxes.YColor = 'none';
    targetAxes.ZColor = 'none';
    targetAxes.Box = 'off';

    plotObjects = targetAxes.Children;
    colorLimit = 0;

    for objectIndex = 1:numel(plotObjects)
        plotObject = plotObjects(objectIndex);

        if ~isprop(plotObject, 'CData')
            continue;
        end

        data = plotObject.CData;

        if isempty(data) || ~isnumeric(data)
            continue;
        end

        % Determine symmetric colour limits without including NaNs.
        objectLimit = max(abs(data(:)), [], 'omitnan');

        if ~isempty(objectLimit) && isfinite(objectLimit)
            colorLimit = max(colorLimit, objectLimit);
        end

        % Apply NaN handling specifically to image objects.
        if isa(plotObject, 'matlab.graphics.primitive.Image')
            configureNanDisplay(plotObject);
        end
    end

    if colorLimit > 0
        clim(targetAxes, [-colorLimit colorLimit]);
    end
end


function configureNanDisplay(imageObject)
%CONFIGURENANDISPLAY Display NaN pixels transparently.
%
%   The transparency mask is automatically regenerated whenever the
%   image CData changes.

    % Set the mask for the currently displayed frame.
    updateNanMask(imageObject);

    % Remove a listener previously created by this function.
    listenerKey = 'addDopplerColormapNanListener';

    if isappdata(imageObject, listenerKey)
        oldListener = getappdata(imageObject, listenerKey);

        if isvalid(oldListener)
            delete(oldListener);
        end
    end

    % FRAMEVIEWER3D changes CData whenever its slider moves. Listen for
    % that change and regenerate AlphaData for the new frame.
    cDataListener = addlistener( ...
        imageObject, ...
        'CData', ...
        'PostSet', ...
        @(~, ~) updateNanMask(imageObject));

    % Store the listener with the image object.
    setappdata(imageObject, listenerKey, cDataListener);
end


function updateNanMask(imageObject)
%UPDATENANMASK Set NaN pixels transparent and finite pixels opaque.

    if ~isvalid(imageObject)
        return;
    end

    data = imageObject.CData;

    if isempty(data)
        return;
    end

    % AlphaData for an indexed/grayscale image has one value per pixel.
    if ismatrix(data)
        imageObject.AlphaData = double(~isnan(data));
        imageObject.AlphaDataMapping = 'none';
    end
end


function colors = interpolateColor(startColor, endColor, numColors)
%INTERPOLATECOLOR Linearly interpolate between two RGB colours.

    weights = linspace(0, 1, numColors).';
    colors = startColor .* (1 - weights) + endColor .* weights;
end