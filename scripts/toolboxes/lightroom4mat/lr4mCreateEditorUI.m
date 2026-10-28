function ui = lr4mCreateEditorUI(numberOfFrames, names, parameters, ...
        isRGB, callbacks)
%lr4mCreateEditorUI - Construct the lightroom4mat editor component tree
%   UI = lr4mCreateEditorUI(NUMFRAMES,NAMES,PARAMETERS,isRGB,CALLBACKS)
%   creates the sage-themed viewer and control panel. UI contains the
%   handles needed by the modal state controller in lr4mRunEditor.

palette = editorPalette();
controlHTMLSource = fullfile(fileparts(mfilename("fullpath")), ...
    "lr4mControl.html");
toolbarHTMLSource = fullfile(fileparts(mfilename("fullpath")), ...
    "lr4mViewerToolbar.html");

ui.Figure = uifigure(Name="lightroom4mat", Tag="lightroom4mat", ...
    Position=[100 100 1200 850], Color=palette.Window);
rootGrid = uigridlayout(ui.Figure, [1 2], ...
    ColumnWidth={"1x", 300}, Padding=[8 8 8 8], ColumnSpacing=8, ...
    BackgroundColor=palette.Window);

[ui.Viewer, ui.Image, ui.SliceControl, ui.ViewToolbar] = createViewer( ...
    rootGrid, numberOfFrames, controlHTMLSource, toolbarHTMLSource, ...
    palette, callbacks);
[ui.CommandArea, ui.StatusLabel, ui.Controls] = createControlPanel( ...
    rootGrid, names, parameters, isRGB, controlHTMLSource, palette, ...
    callbacks);

ui.Figure.CloseRequestFcn = callbacks.Cancel;
end

function [viewer, imageObject, sliceControl, viewerToolbar] = ...
        createViewer(parent, numberOfFrames, controlHTMLSource, ...
        toolbarHTMLSource, palette, callbacks)
%createViewer - Create the viewer, slice navigator, and floating actions
viewerPanel = uipanel(parent, BorderType="none", ...
    BackgroundColor=palette.Window, Tag="lightroom4mat.ViewerPanel");
viewerPanel.Layout.Row = 1;
viewerPanel.Layout.Column = 1;
viewerPanel.AutoResizeChildren = "off";

% The grid remains the structural layout. The HTML toolbar is a small
% overlay sibling so it can use alpha transparency over the rendered image.
leftGrid = uigridlayout(viewerPanel, [2 1], RowHeight={"1x", 54}, ...
    RowSpacing=10, Padding=[0 0 0 0], BackgroundColor=palette.Window);

viewer = viewer2d(leftGrid);
viewer.Layout.Row = 1;
viewer.Layout.Column = 1;
if isprop(viewer, "Tag")
    viewer.Tag = "lightroom4mat.Viewer";
end
if isprop(viewer, "BackgroundColor")
    viewer.BackgroundColor = palette.Viewer;
end
imageObject = imageshow([], Parent=viewer, DisplayRangeMode="data-range");

sliceGrid = uigridlayout(leftGrid, [1 1], Padding=[8 2 8 2], ...
    BackgroundColor=palette.Window);
sliceGrid.Layout.Row = 2;
sliceGrid.Layout.Column = 1;
sliceControl = uihtml(sliceGrid, HTMLSource=controlHTMLSource, ...
    Data=lr4mControlData(sprintf("Slice 1/%d", numberOfFrames), 1, ...
    [1 max(2, numberOfFrames)], Step=1, ShowReset=false, ...
    ShowValue=false, ResetValue=1), ...
    Tag="lightroom4mat.SliceControl");

if numberOfFrames == 1
    % Preserve one layout for every input shape; collapsing the second row
    % avoids maintaining a separate single-image component tree.
    leftGrid.RowHeight{2} = 0;
else
    sliceControl.DataChangedFcn = callbacks.ChangeSlice;
end

viewerToolbar = uihtml(viewerPanel, HTMLSource=toolbarHTMLSource, ...
    Data=struct(Action="", Sequence=0), ...
    DataChangedFcn=callbacks.ViewAction, ...
    Tag="lightroom4mat.ViewToolbar");
viewerPanel.SizeChangedFcn = @(~, ~) resizeViewerPanel( ...
    viewerPanel, viewerToolbar, numberOfFrames > 1);
resizeViewerPanel(viewerPanel, viewerToolbar, numberOfFrames > 1);
end

function [commandArea, statusLabel, controls] = createControlPanel(parent, ...
        names, parameters, isRGB, htmlSource, palette, callbacks)
%createControlPanel - Create command, action, and adjustment controls
controlPanel = uipanel(parent, BackgroundColor=palette.Panel, ...
    BorderType="none", ...
    Tag="lightroom4mat.ControlPanel");
controlPanel.Layout.Row = 1;
controlPanel.Layout.Column = 2;

numberOfControls = numel(names);
% Scrolling belongs to the fixed-height grid rather than its panel. This
% makes its content taller than the viewport at small window sizes,
% which is the condition MATLAB uses to show a vertical scrollbar.
controlGrid = uigridlayout(controlPanel, [numberOfControls + 4 1], ...
    RowHeight=[{72, 34, 34, "fit"}, ...
    repmat({54}, 1, numberOfControls)], Padding=[10 10 10 10], ...
    RowSpacing=5, BackgroundColor=palette.Panel, Scrollable="on", ...
    Tag="lightroom4mat.ControlGrid");

commandArea = uitextarea(controlGrid, Editable="off", ...
    BackgroundColor=palette.Window, FontColor=palette.Text, ...
    Tag="lightroom4mat.Command");
commandArea.Layout.Row = 1;

createButtonRow(controlGrid, 2, ["Reset All" "Copy Command"], ...
    ["lightroom4mat.Reset" "lightroom4mat.Copy"], ...
    {callbacks.ResetAll callbacks.CopyCommand}, [false false], palette);
createButtonRow(controlGrid, 3, ["Done" "Cancel"], ...
    ["lightroom4mat.Done" "lightroom4mat.Cancel"], ...
    {callbacks.Finish callbacks.Cancel}, [true false], palette);

statusLabel = uilabel(controlGrid, Text="Ready", ...
    FontColor=palette.Text, Tag="lightroom4mat.Status");
statusLabel.Layout.Row = 4;

controls = struct();
colorOnlyNames = ["Saturation" "Vibrance" "Warmth" "Tint"];
for index = 1:numberOfControls
    name = names(index);
    isEnabled = isRGB || ~ismember(name, colorOnlyNames);
    control = uihtml(controlGrid, HTMLSource=htmlSource, ...
        Data=lr4mControlData(name, parameters.(name), [-10 10], ...
        Enabled=isEnabled), ...
        DataChangedFcn=@(source, event) ...
        callbacks.AdjustmentChanged(name, source, event), ...
        Tag="lightroom4mat." + name + ".Control");
    control.Layout.Row = index + 4;

    % UserData stores immutable presentation metadata. The callback can
    % rebuild Data without rediscovering whether a control is color-only.
    control.UserData = struct(Name=name, Enabled=isEnabled);
    controls.(name) = control;
end
end

function resizeViewerPanel(panel, toolbar, hasSliceNavigator)
%resizeViewerPanel - Place zoom actions beside the viewer zoom percentage
toolbarSize = [126 22];
percentageWidth = 110;
percentageGap = 5;
viewerEdgeInset = 7;
sliceRowHeight = 54;
rowSpacing = 10;

% viewer2d draws its percentage badge at the lower-right of its viewport.
% The badge is approximately 110 pixels wide in R2024b. Positioning the
% custom actions immediately to its left makes the three controls read as
% one zoom cluster without covering the image or the slice navigator.
panelSize = double(panel.InnerPosition(3:4));
percentageLeft = 1 + panelSize(1) - viewerEdgeInset - percentageWidth;
left = percentageLeft - percentageGap - toolbarSize(1);
bottom = 1 + viewerEdgeInset;
if hasSliceNavigator
    bottom = bottom + sliceRowHeight + rowSpacing;
end

% Very narrow windows may not have enough room for both badges. Keep the
% action pill inside the viewer while preserving its alignment whenever
% the normal Explorer layout provides sufficient space.
left = max(1 + viewerEdgeInset, left);
bottom = max(viewerEdgeInset, bottom);
toolbar.Position = [round(left) round(bottom) toolbarSize];
end

function createButtonRow(parent, row, labels, tags, callbacks, ...
        primaryFlags, palette)
%createButtonRow - Create and consistently style a two-button action row
buttonGrid = uigridlayout(parent, [1 2], ColumnWidth={"1x", "1x"}, ...
    Padding=[0 0 0 0], BackgroundColor=palette.Panel);
buttonGrid.Layout.Row = row;

for index = 1:2
    button = uibutton(buttonGrid, Text=labels(index), Tag=tags(index));
    button.ButtonPushedFcn = callbacks{index};
    styleButton(button, primaryFlags(index), palette);
end
end

function styleButton(button, isPrimary, palette)
%styleButton - Apply the shared sage theme to an action button
button.FontColor = palette.Text;
button.BackgroundColor = palette.Control;
if isPrimary
    button.FontColor = [1 1 1];
    button.BackgroundColor = palette.Accent;
end
end

function palette = editorPalette()
%editorPalette - Define semantic colors used throughout the editor
palette = struct( ...
    Window=[0.89 0.92 0.84], ...
    Panel=[231 237 220] / 255, ...
    Control=[0.82 0.87 0.75], ...
    Viewer=[0.73 0.79 0.68], ...
    Text=[0.18 0.23 0.18], ...
    Accent=[0.38 0.50 0.33]);
end
