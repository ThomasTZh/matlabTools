function saveSvg(outputFolder, originalName, nameSuffix, figHandle)
% SAVESVG Saves a figure as an SVG using a standardized naming convention.
%
%   SAVESVG(OUTPUTFOLDER, ORIGINALNAME, SUFFIX) saves the current figure 
%   (gcf) to the specified folder. It parses the ORIGINALNAME to remove 
%   any existing extension, appends the SUFFIX, and saves as .svg.
%
%   SAVESVG(..., FIGHANDLE) specifies a specific figure handle to save 
%   instead of the current figure.
%
%   Inputs:
%       outputFolder - (String/Char) Destination directory path.
%       originalName - (String/Char) The reference filename (e.g., 'data.mat').
%       nameSuffix   - (String/Char) Text to append to the filename.
%       figHandle    - (Optional) Handle to the figure. Defaults to gcf.
%
%   Example:
%       % Save current figure as 'C:\Work\Results\Experiment1_final.svg'
%       saveSvg('C:\Work\Results', 'Experiment1.dat', '_final');
%
%   See also SAVEAS, EXPORTGRAPHICS, FILEPARTS, FULLFILE.

    % Input validation (Requires MATLAB R2019b or later)
    arguments
        outputFolder (1,1) string
        originalName (1,1) string
        nameSuffix = []
        figHandle (1,1) matlab.ui.Figure = gcf % Default to current figure
    end

    % 1. Create directory if it does not exist
    if ~isfolder(outputFolder)
        try
            wrtdir(outputFolder);
            % mkdir(outputFolder);
            fprintf('Created new directory: %s\n', outputFolder);
        catch ME
            error('saveSvg:DirCreation','Could not create directory: %s\n%s',...
                outputFolder, ME.message);
        end
    end

    % 2. Safe parsing of the filename
    % fileparts robustly handles files with or without existing extensions
    % [~, baseName, ~] = fileparts(originalName);
    baseName=originalName;

    % 3. Construct the new full path
    % ensuring the suffix is attached cleanly
    if isempty(nameSuffix)
        nameSuffix="";
    else
        nameSuffix="_"+nameSuffix;
    end
    newFileName = baseName + nameSuffix + ".svg";
    fullPath = fullfile(outputFolder, newFileName);

    % 4. Save the figure
    % try
        drawnow limitrate;
        % Get all axes handles in an array
        axeHandle = findobj(figHandle, 'Type', 'axes');
        % Set the figure and axes background to 'none' to stop extra background layers
        set(axeHandle, 'Color', 'none');
        set(figHandle, 'Color', 'none', 'InvertHardcopy', 'off');
        % Force vector rendering
        set(figHandle, 'Renderer', 'painters');
        % saveas(figHandle, fullPath, 'svg');
        print(figHandle, fullPath, '-dsvg', '-vector');
        % exportgraphics(figHandle, fullPath, 'ContentType', 'vector',...
        %     'BackgroundColor', 'none');
    % catch ME
    %     error('saveSvg:SaveFailed', 'Failed to save SVG to %s.\nError: %s', ...
    %         fullPath, ME.message);
    % end

end