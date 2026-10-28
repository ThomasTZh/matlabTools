function selectedFolders = uigetfolder(startPath, regPattern, dlgTitle, varargin)
%UIGETFOLDER Open a dialog box to select folders matching a pattern.
%   selectedFolders = UIGETFOLDER(startPath, regPattern, dlgTitle) opens a 
%   list dialog box containing folders within 'startPath' that match the 
%   regular expression 'regPattern'. The user can select one or multiple 
%   folders based on the default configuration.
%
%   selectedFolders = UIGETFOLDER(..., 'Name', Value) specifies additional
%   options using one or more name-value pair arguments.
%
%   Description
%   -----------
%   This function scans a specified directory for subdirectories, filters
%   them based on a provided regular expression, and presents the valid
%   candidates in a list dialog. It is designed to overcome the limitations
%   of uigetdir, which allows only single selection and lacks regex filtering.
%
%   Syntax
%   ------
%   selectedFolders = uigetfolder(startPath, regPattern, dlgTitle)
%   selectedFolders = uigetfolder(..., 'MultiSelect', 'on')
%   selectedFolders = uigetfolder(..., 'MultiSelect', 'off')
%
%   Input Arguments
%   ---------------
%   startPath   : (char/string) The root directory to search.
%   regPattern  : (char/string) Regular expression pattern to filter folder names.
%   dlgTitle    : (char/string) Title text for the selection dialog window.
%
%   Name-Value Pair Arguments
%   -------------------------
%   'MultiSelect' : (char/string) Controls multiple selection mode.
%                   'on'  - Allows selecting multiple folders (Default).
%                   'off' - Allows selecting only one folder.
%
%   Output Arguments
%   ----------------
%   selectedFolders : (cell array of chars) Full paths of the selected folders.
%                     Returns an empty cell array {} if the user cancels or 
%                     no matching folders are found.
%
%   Examples
%   --------
%   % 1. Select multiple folders starting with 'Project' followed by digits
%   pattern = 'Project\d+';
%   startDir = fullfile(pwd);
%   myFolders = uigetfolder(startDir, pattern, 'Select Project Folders');
%
%   % 2. Select a single folder containing 'data' (case insensitive)
%   pattern = '(?i).*data.*';
%   myFolder = uigetfolder(pwd, pattern, 'Pick one', 'MultiSelect', 'off');
%
%   See also UIGETDIR, UIGETFILE, LISTDLG, REGEXP.

%   Program by TZ 09 Feb 2026

    %% 1. Input Validation and Parsing
    p = inputParser;
    
    % Validate required inputs
    addRequired(p, 'startPath', @(x) validateattributes(x, {'char', 'string'}, {'scalartext', 'nonempty'}));
    addRequired(p, 'regPattern', @(x) validateattributes(x, {'char', 'string'}, {'scalartext', 'nonempty'}));
    addRequired(p, 'dlgTitle', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    
    % Validate optional Name-Value pair
    expectedMultiSelect = {'on', 'off'};
    addParameter(p, 'MultiSelect', 'on', @(x) any(validatestring(x, expectedMultiSelect)));
    
    parse(p, startPath, regPattern, dlgTitle, varargin{:});
    
    % Extract parsed values to variables
    path2search = char(p.Results.startPath);
    regexStr = char(p.Results.regPattern);
    titleStr = char(p.Results.dlgTitle);
    multiSelectMode = char(p.Results.MultiSelect);
    
    % Ensure path exists
    if ~exist(path2search, 'dir')
        error('uigetfolder:DirNotFound', 'The specified start path does not exist: %s', path2search);
    end

    %% 2. Data Retrieval and Filtering
    % Get all contents of the directory
    dirData = dir(path2search);
    
    % Filter for directories only, excluding '.' and '..'
    isDir = [dirData.isdir];
    dirNames = {dirData.name};
    validDirsIndex = isDir & ~ismember(dirNames, {'.', '..'});
    candidateFolders = dirNames(validDirsIndex);
    
    if isempty(candidateFolders)
        warning('uigetfolder:NoSubfolders', 'No subfolders found in the specified path.');
        selectedFolders = {};
        return;
    end
    
    % Apply Regular Expression to filter folder names
    matchIndices = regexp(candidateFolders, regexStr);
    
    % regexp returns a cell array of indices; empty cells mean no match
    hasMatch = ~cellfun(@isempty, matchIndices);
    filteredFolders = candidateFolders(hasMatch);
    
    if isempty(filteredFolders)
        % Using a message box to inform user instead of silently failing
        msgbox(sprintf('No folders found matching pattern "%s" in:\n%s', regexStr, path2search), ...
               'No Matches Found', 'warn');
        selectedFolders = {};
        return;
    end

    % Natural-order sort
    filteredFolders=natsort(filteredFolders);

    %% 3. User Interface (Selection)
    % Configure selection mode for listdlg
    if strcmpi(multiSelectMode, 'on')
        listSelectionMode = 'multiple';
    else
        listSelectionMode = 'single';
    end
    
    % Calculate dialog dimensions based on screen size for better UX
    screenSize = get(0, 'ScreenSize');
    dlgWidth = round(screenSize(3)*0.1562);
    dlgHeight = min(dlgWidth, 50 + 15 * length(filteredFolders)); 
    
    [selectionIdx, isSelectionMade] = listdlg(...
        'PromptString', {titleStr, ' ', ['Path: ' path2search]}, ...
        'SelectionMode', listSelectionMode, ...
        'ListString', filteredFolders, ...
        'ListSize', [dlgWidth, dlgHeight], ...
        'Name', 'Select Folder(s)');

    %% 4. Output Construction
    if isSelectionMade
        % Retrieve names based on indices
        names2return = filteredFolders(selectionIdx);
        
        % Construct full paths
        selectedFolders = fullfile(path2search, names2return);
        
        % Ensure output is always a cell array for consistency, or adjust
        % here if specific single-string output is preferred for 'off' mode.
        % For robustness, a cell array is usually preferred to handle 1 or N.
        if ischar(selectedFolders) 
            selectedFolders = {selectedFolders};
        end
    else
        % User cancelled
        selectedFolders = 0;
    end

end