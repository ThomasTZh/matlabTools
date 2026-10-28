function command = lr4mRunEditor(inputImage, dimensions, request, ...
        inputVariableName)
%lr4mRunEditor - Run the modal lightroom4mat command editor
%   COMMAND = lr4mRunEditor(A,DIMENSIONS,REQUEST,NAME) previews adjustments
%   and returns a canonical non-GUI command. Closing or cancelling the
%   editor returns an empty string.

command = "";
wasAccepted = false;
lastPreviewTime = tic;
parameters = request.Parameters;
effectiveParameters = request.EffectiveParameters;
isRGB = request.IsRGB;
colorMode = request.ColorMode;
colorDimension = request.ColorDimension;

% Dimensions after row, column, and the optional color axis form the GUI's
% linear slice sequence. ind2sub in lr4mExtractDisplaySlice preserves
% MATLAB's column-major ordering for N-D data.
frameDimensions = 3:ndims(inputImage);
if isRGB
    frameDimensions = setdiff(frameDimensions, colorDimension, "stable");
end
inputSize = size(inputImage);
numberOfFrames = max(1, prod(inputSize(frameDimensions)));

% UI construction is intentionally separated from modal state transitions.
% The callbacks remain nested because they jointly own PARAMETERS, COMMAND,
% and the accepted/cancelled result of this editor invocation.
callbacks.AdjustmentChanged = @adjustmentChanged;
callbacks.ChangeSlice = @changeSlice;
callbacks.ResetAll = @resetAll;
callbacks.CopyCommand = @copyCommand;
callbacks.Finish = @finishEditor;
callbacks.Cancel = @cancelChanges;
callbacks.ViewAction = @viewerActionChanged;

names = lr4mAdjustmentNames();
ui = lr4mCreateEditorUI(numberOfFrames, names, parameters, isRGB, ...
    callbacks);

updateCommand();
updatePreview();
drawnow;
uiwait(ui.Figure);

if isvalid(ui.Figure)
    delete(ui.Figure);
end
if ~wasAccepted
    command = "";
    warning("lightroom4mat:Cancelled", ...
        "lightroom4mat editing was cancelled.");
end

    function adjustmentChanged(name, source, ~)
        % HTML controls report whether a change is continuous dragging or a
        % committed value. Both update state immediately; only continuous
        % preview rendering is throttled to approximately 20 frames/second.
        data = source.Data;
        value = lr4mQuantizeAdjustment(data.Value);
        parameters.(name) = value;
        effectiveParameters.(name) = value;
        source.Data = lr4mControlData(name, value, [-10 10], ...
            Enabled=source.UserData.Enabled);
        updateCommand();

        phase = "changed";
        if isstruct(data) && isfield(data, "Phase")
            phase = string(data.Phase);
        end
        if phase ~= "moving" || toc(lastPreviewTime) >= 0.05
            updatePreview();
            lastPreviewTime = tic;
        end
    end

    function changeSlice(source, ~)
        frameIndex = min(numberOfFrames, ...
            max(1, round(source.Data.Value)));
        source.Data = sliceControlData(frameIndex);
        updatePreview();
    end

    function resetAll(~, ~)
        for resetName = names
            parameters.(resetName) = 0;
            effectiveParameters.(resetName) = 0;
            control = ui.Controls.(resetName);
            control.Data = lr4mControlData(resetName, 0, [-10 10], ...
                Enabled=control.UserData.Enabled);
        end
        updateCommand();
        updatePreview();
    end

    function copyCommand(~, ~)
        clipboard("copy", char(buildCommand()));
        ui.StatusLabel.Text = "Command copied";
    end

    function finishEditor(~, ~)
        command = buildCommand();
        wasAccepted = true;
        uiresume(ui.Figure);
    end

    function cancelChanges(~, ~)
        % Window-close and Cancel deliberately share this path so neither
        % can accidentally return a partially edited command.
        if isvalid(ui.Figure)
            uiresume(ui.Figure);
        end
    end

    function updateCommand()
        ui.CommandArea.Value = {char(buildCommand())};
    end

    function currentCommand = buildCommand()
        currentCommand = lr4mBuildCommand(inputVariableName, dimensions, ...
            parameters, colorMode, colorDimension);
    end

    function updatePreview()
        frameIndex = min(numberOfFrames, ...
            max(1, round(ui.SliceControl.Data.Value)));
        originalSlice = lr4mExtractDisplaySlice(inputImage, ...
            frameDimensions, frameIndex, isRGB, colorDimension);

        % Previewing only the displayed plane keeps interaction responsive.
        % Apply-by-command still performs exact filtering across all selected
        % N-D axes, so local-detail results can differ slightly.
        previewColorDimension = 3;
        preview = lr4mProcessArray(originalSlice, [1 2], ...
            effectiveParameters, isRGB, previewColorDimension);
        ui.Image.Data = preview;
        ui.SliceControl.Data = sliceControlData(frameIndex);
        ui.StatusLabel.Text = "Preview uses the displayed 2-D plane";
        drawnow limitrate;
    end

    function data = sliceControlData(frameIndex)
        data = lr4mControlData(sprintf("Slice %d/%d", frameIndex, ...
            numberOfFrames), frameIndex, [1 max(2, numberOfFrames)], ...
            Step=1, ShowReset=false, ShowValue=false, ResetValue=1);
    end

    function fitView(~, ~)
        lr4mSetViewerZoom(ui.Viewer, "fit", size(ui.Image.Data));
        ui.StatusLabel.Text = "View fitted to window";
        drawnow limitrate;
    end

    function viewerActionChanged(source, ~)
        % Treat HTML data as an external boundary even though the payload is
        % generated locally. Unknown or malformed actions are ignored.
        data = source.Data;
        if ~isstruct(data) || ~isfield(data, "Action")
            return
        end

        action = lower(string(data.Action));
        if action == "fit"
            fitView([], []);
        elseif action == "actualsize"
            showActualSize([], []);
        end
    end

    function showActualSize(~, ~)
        lr4mSetViewerZoom(ui.Viewer, "actual", size(ui.Image.Data));
        ui.StatusLabel.Text = "View set to actual pixel size";
        drawnow limitrate;
    end
end
