function hFig = frameViewer3D(data, segLines)
% FRAMEVIEWER3D Interactive viewer for 3D tomography data with segmentation.
%   hFig = FRAMEVIEWER3D(DATA, SEGLINES) displays a GUI to scroll through the
%   frames of a 3D volume. It overlays segmentation lines on the frames.
%   Returns the figure handle. Use uiwait(hFig) to pause execution until closed.
%
%   INPUTS:
%       DATA     - A numeric array of size [nZ, nC, nB] or [nZ, nC, 1, nB].
%                  nZ: Number of rows (height)
%                  nC: Number of columns (width)
%                  nB: Number of frames/slices (depth)
%
%       SEGLINES - A numeric array of size [nC, nB, nLines].
%                  Contains the row indices (Y-coordinates) for the lines.
%                  - Dimension 1 (nC) corresponds to columns of the image.
%                  - Dimension 2 (nB) corresponds to the frame index.
%                  - Dimension 3 (nLines) is the number of lines.
%
%   USAGE:
%       frameViewer3D(volumeData, segmentationLines);
%
%   EXAMPLE:
%       % Generate random data
%       data = rand(100, 128, 50); 
%       % Generate 2 random segmentation lines moving over frames
%       myLines = repmat(50*ones(128, 1), [1, 50, 2]) + randn(128, 50, 2)*2;
%       frameViewer3D(data, myLines);


    % ---------------------------------------------------------
    % 1. INPUT PARSING AND VALIDATION
    % ---------------------------------------------------------
    
    if nargin < 1
        error('frameViewer3D:NotEnoughInputs', 'Not enough input arguments. Data is required.');
    end
    
    if nargin < 2
        segLines = [];
    end
    
    % Handle 4D input and ensure data is squeezed
    data = double(data);
    data = squeeze(data);
    
    [nRows, nCols, nFrames] = size(data);
    
    numSegLines = 0;
    if ~isempty(segLines)
        [segC, segB, ~] = size(segLines);
        if segC ~= nCols || segB ~= nFrames
             warning('frameViewer3D:DimMismatch', 'segLines dimensions do not match data.');
        end
        numSegLines = size(segLines, 3);
    end

    % ---------------------------------------------------------
    % 2. GUI SETUP
    % ---------------------------------------------------------
    
    hFig = figure('Name', '3D Frame Viewer (Optimized)', ...
                  'NumberTitle', 'off', ...
                  'MenuBar', 'none', ...
                  'ToolBar', 'figure', ...
                  'Position', [100, 100, 700, 600], ...
                  'Color', [0.94 0.94 0.94]);

    % Maximize axes: occupy full width, leave 10% height at bottom for slider
    hAx = axes('Parent', hFig, ...
               'Units', 'normalized', ...
               'Position', [0, 0.1, 1, 0.9]);
    
    % Initialize Slice Index
    currentSlice = round(nFrames / 2);
    if currentSlice < 1, currentSlice = 1; end

    % OPTIMIZATION 1: Pre-calculate Global Color Limits
    globalMin = min(data(:));
    globalMax = max(data(:));
    if globalMin == globalMax, globalMax = globalMin + 1; end 

    % Display the initial image
    hImg = image(data(:, :, currentSlice), 'Parent', hAx, 'CDataMapping', 'scaled');
    colormap(hAx, gray); 
    axis(hAx, 'image');  
    axis(hAx, 'off'); % Remove rulers/ticks
    % Removed colorbar and title
    
    % OPTIMIZATION 2: Freeze Axis Properties
    set(hAx, 'CLim', [globalMin, globalMax]);
    set(hAx, 'XLim', [0.5, nCols + 0.5], 'XLimMode', 'manual');
    set(hAx, 'YLim', [0.5, nRows + 0.5], 'YLimMode', 'manual');
    
    % Plot Segmentation Lines
    hold(hAx, 'on');
    hLines = gobjects(numSegLines, 1);
    lineColors = lines(numSegLines); 
    xVector = 1:nCols;
    
    if numSegLines > 0
        for k = 1:numSegLines
            if size(segLines, 2) >= currentSlice
                yData = segLines(:, currentSlice, k);
            else
                yData = NaN(nCols, 1);
            end
            hLines(k) = plot(hAx, xVector, yData, ...
                             'Color', lineColors(k,:), ...
                             'LineWidth', 0.1, ...
                             'HitTest', 'off', ... 
                             'PickableParts', 'none'); 
        end
    end
    hold(hAx, 'off');

    % ---------------------------------------------------------
    % 3. CONTROLS
    % ---------------------------------------------------------
    
    sliderStep = [1/(max(1, nFrames-1)), 10/(max(1, nFrames-1))];
    if nFrames <= 1, sliderStep = [0.1 1]; end

    % Move controls to the very bottom to reduce wasted space
    hSlider = uicontrol('Parent', hFig, ...
                        'Style', 'slider', ...
                        'Units', 'normalized', ...
                        'Position', [0.2, 0.025, 0.75, 0.05], ... % Wider slider
                        'Min', 1, ...
                        'Max', nFrames, ...
                        'Value', currentSlice, ...
                        'SliderStep', sliderStep, ...
                        'Callback', @updateSlice); 

    % OPTIMIZATION 3: Continuous Listener
    addlistener(hSlider, 'ContinuousValueChange', @updateSlice);

    hLabel = uicontrol('Parent', hFig, ...
                       'Style', 'text', ...
                       'Units', 'normalized', ...
                       'Position', [0.02, 0.02, 0.16, 0.06], ...
                       'String', sprintf('Frame: %d', currentSlice), ...
                       'FontSize', 10, ...
                       'BackgroundColor', [0.94 0.94 0.94], ...
                       'HorizontalAlignment', 'left');

    % ---------------------------------------------------------
    % 4. CALLBACK FUNCTIONS
    % ---------------------------------------------------------
    
    function updateSlice(source, ~)
        val = round(source.Value);
        val = max(1, min(val, nFrames));
        
        % Update Image Data
        set(hImg, 'CData', data(:, :, val));
        
        % Update Segmentation Lines
        if numSegLines > 0
            for i = 1:numSegLines
                set(hLines(i), 'YData', segLines(:, val, i));
            end
        end
        
        set(hLabel, 'String', sprintf('Frame: %d', val));
        
        % OPTIMIZATION 4: Limit Rate
        drawnow limitrate; 
    end

end