function [hLines, hText] = scaleBar(axialPixelSize, lateralPixelSize, ...
    loc2place, options)
%SCALEBAR Adds L-shaped scale bars to 2D image axes.
%
% Description:
%   scaleBar(...) adds a scale bar to the specified or current axes.
%   The scale bars are L-shaped, representing the same distance for both
%   axial (typically Y) and lateral (typically X) directions.
%
% Syntax:
%   scaleBar(axialPixelSize, lateralPixelSize, loc2place)
%   scaleBar(..., 'axes2target', axHandle)
%   scaleBar(..., 'dist2measure', val)
%   scaleBar(..., 'width4bar', val)
%   scaleBar(..., 'color4bar', color)
%   scaleBar(..., 'size4font', val)
%   scaleBar(..., 'loc4text', loc)
%   scaleBar(..., 'space2text', val)
%   scaleBar(..., 'margin4x', val)
%   scaleBar(..., 'margin4y', val)
%
% Input Arguments:
%   axialPixelSize   - Size of axial pixel (mm/pixel).
%   lateralPixelSize - Size of lateral pixel (mm/pixel).
%   loc2place        - Location string ('northwest', 'southeast', etc).
%
% Name-Value Arguments:
%   axes2target  - Target axes handle. Default: gca.
%   dist2measure - Distance in mm. Default: 0.5 (500 um).
%   width4bar    - Width of scale bar. Default: 2.
%   color4bar    - Color of bar and text. Default: 'w'.
%   size4font    - Font size for text. Default: 12.
%   loc4text     - Text location ('inside', 'outside'). Default: 'inside'.
%   space2text   - Spacing in pixels. Default: size4font / 2.
%   margin4x     - X margin from axes edge. Default: 5% of X range.
%   margin4y     - Y margin from axes edge. Default: 5% of Y range.
%
% Output Arguments:
%   hLines - Handle to the line object.
%   hText  - Handle to the text object.
%
% Examples:
%   scaleBar(0.1, 0.1, 'southeast', 'dist2measure', 1, 'color4bar', 'r');

arguments
    axialPixelSize (1,1) double {mustBePositive}
    lateralPixelSize (1,1) double {mustBePositive}
    loc2place (1,:) char {mustBeMember(loc2place, {'northwest', ...
        'northeast', 'southwest', 'southeast', 'north', 'south', ...
        'east', 'west'})}
    options.axes2target (1,1) matlab.graphics.axis.Axes = gca
    options.dist2measure (1,1) double {mustBePositive} = 0.5
    options.width4bar (1,1) double {mustBePositive} = 2
    options.color4bar = 'w'
    options.size4font (1,1) double {mustBePositive} = 12
    options.loc4text (1,:) char {mustBeMember(options.loc4text, ...
        {'inside', 'outside'})} = 'inside'
    options.space2text (1,1) double = -1
    options.margin4x (1,1) double = -1
    options.margin4y (1,1) double = -1
end

% Assign default spacing if not provided
if options.space2text == -1
    options.space2text = options.size4font / 2;
end

ax2draw = options.axes2target;
hold(ax2draw, 'on');

% Retrieve axes limits to calculate margins
lim4x = ax2draw.XLim;
lim4y = ax2draw.YLim;
range4x = lim4x(2) - lim4x(1);
range4y = lim4y(2) - lim4y(1);

% Evaluate dynamic defaults for margins
if options.margin4x == -1
    margin4x = 0.05 * range4x;
else
    margin4x = options.margin4x;
end

if options.margin4y == -1
    margin4y = 0.05 * range4y;
else
    margin4y = options.margin4y;
end

% Convert physical distance to pixel lengths
len4axial = options.dist2measure / axialPixelSize;
len4lateral = options.dist2measure / lateralPixelSize;

% Determine quadrant signs based on requested location
if contains(lower(loc2place), 'north')
    sgn4y = 1;
    y1 = lim4y(1) + margin4y;
else
    sgn4y = -1;
    y1 = lim4y(2) - margin4y;
end

if contains(lower(loc2place), 'west') || strcmpi(loc2place, 'south') || ...
   strcmpi(loc2place, 'north') 
    sgn4x = 1;
    x1 = lim4x(1) + margin4x;
else
    sgn4x = -1;
    x1 = lim4x(2) - margin4x;
end

x2 = x1 + sgn4x * len4lateral;
y2 = y1 + sgn4y * len4axial;

% Draw lines as a single L-shape sharing corner (x1, y1)
xPts = [x2, x1, x1];
yPts = [y1, y1, y2];

hLines = plot(ax2draw, xPts, yPts, 'Color', options.color4bar, ...
    'LineWidth', options.width4bar, 'Clipping', 'off');

% Text preparation and unit formatting
dist4um = options.dist2measure * 1000;
if dist4um >= 1000
    text2show = sprintf('%g mm', options.dist2measure);
else
    text2show = sprintf('%g \\mum', dist4um);
end

% Text placement logic
if strcmpi(options.loc4text, 'inside')
    dir4txt = 1;
else
    dir4txt = -1;
end

x4txt = x1 + dir4txt * sgn4x * options.space2text;
y4txt = y1 + dir4txt * sgn4y * options.space2text;

% Dynamic alignment to prevent text from overlapping the scale bar
if dir4txt * sgn4x == 1
    align4horz = 'left';
else
    align4horz = 'right';
end

if dir4txt * sgn4y == 1
    align4vert = 'top';
else
    align4vert = 'bottom';
end

% Render text
hText = text(ax2draw, x4txt, y4txt, text2show, ...
    'Color', options.color4bar, 'FontSize', options.size4font, ...
    'HorizontalAlignment', align4horz, 'VerticalAlignment', align4vert);

end