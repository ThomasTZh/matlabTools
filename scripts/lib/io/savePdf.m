function savePdf(outputFolder, originalName, nameSuffix, figHandle)
% SAVEPDF Saves a figure as a PDF using exportgraphics.
%
%   SAVEPDF(OUTPUTFOLDER, ORIGINALNAME, SUFFIX) saves the current figure 
%   (gcf) to the specified folder. It parses the ORIGINALNAME to remove 
%   any existing extension, appends the SUFFIX, and saves as .pdf.
%
%   SAVEPDF(..., FIGHANDLE) specifies a specific figure handle.
%
%   Inputs:
%       outputFolder - (String/Char) Destination directory path.
%       originalName - (String/Char) The reference filename.
%       nameSuffix   - (String/Char) Text to append to the filename.
%       figHandle    - (Optional) Handle to the figure. Defaults to gcf.
%
%   Notes:
%       - Requires MATLAB R2020a or later (for exportgraphics).
%       - 'ContentType' is forced to 'vector' for high-quality text/lines.
%       - exportgraphics automatically crops tight whitespace around the figure.
%
%   Example:
%       savePdf('C:\Reports', 'Analysis.mat', '_PlotA');

    % Input validation
    arguments
        outputFolder (1,1) string
        originalName (1,1) string
        nameSuffix = []
        figHandle (1,1) matlab.ui.Figure = gcf 
    end

    % 1. Create directory if it does not exist
    if ~isfolder(outputFolder)
        try
            wrtdir(outputFolder);
            % mkdir(outputFolder);
            fprintf('Created new directory: %s\n', outputFolder);
        catch ME
            error('savePdf:DirCreation', 'Could not create directory: %s\n%s', ...
                outputFolder, ME.message);
        end
    end

    % 2. Safe parsing of the filename
    [~, baseName, ~] = fileparts(originalName);

    % 3. Construct the new full path
    % ensuring the suffix is attached cleanly
    if isempty(nameSuffix)
        nameSuffix="";
    else
        nameSuffix="_"+nameSuffix;
    end
    newFileName = baseName + nameSuffix + ".pdf";
    fullPath = fullfile(outputFolder, newFileName);

    % 4. Save the figure using exportgraphics
    try
        % Find all axes objects in the figure to modify toolbars
        allAxes=findobj(figHandle,"Type","axes");
        % Loop through axes to cache and hide toolbars
        for idx4ax = 1:numel(allAxes)
            if ~isempty(allAxes(idx4ax).Toolbar)
                allAxes(idx4ax).Toolbar.Visible = "off";
            end
        end
        % Force immediate rendering update to clear toolbar artifacts
        drawnow;
        % 'ContentType', 'vector' ensures text remains editable and lines sharp
        exportgraphics(figHandle, fullPath, 'ContentType', 'vector');
    catch ME
        error('savePdf:SaveFailed', 'Failed to save PDF to %s.\nError: %s', ...
            fullPath, ME.message);
    end

end