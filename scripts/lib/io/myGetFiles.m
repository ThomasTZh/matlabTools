function [fileNames, fileFolders] = myGetFiles(fileFilter, options)
%myGetFiles Selects files or folders based on specified filters.
%
% Description:
%   myGetFiles opens a dialog to select files or folders and retrieves
%   the corresponding file names and folder paths matching the filter.
%
% Syntax:
%   [fileNames, fileFolders] = myGetFiles(fileFilter)
%   [...] = myGetFiles(fileFilter, Name, Value)
%
% Input Arguments:
%   fileFilter - Pattern 2 filter files (char or string).
%
% Name-Value Arguments:
%   mode         - Selection mode: "file" (default) or "folder".
%   parentPath   - Starting directory path (default is pwd).
%   subFolders   - Subfolder(s) 2 include (string array or cell).
%   folderFilter - Pattern 2 filter folders (used in folder mode).
%
% Output Arguments:
%   fileNames    - String array of selected file names.
%   fileFolders  - String array of corresponding folder paths.
%
% Examples:
%   [n, f] = myGetFiles("*.txt");
%   [n, f] = myGetFiles("*.dcm", "mode", "folder");
%
%   See also UIGETFOLDER, UIGETDIR, UIGETFILE, LISTDLG, REGEXP.

%   Program by TZ 23 Feb 2026

arguments
    fileFilter (1,:) {mustBeTextScalar}
    options.mode (1,:) {mustBeTextScalar, ...
        mustBeMember(options.mode, ["file", "folder"])} = "file"
    options.parentPath (1,:) {mustBeTextScalar} = pwd
    options.subFolders {mustBeText} = ""
    options.folderFilter (1,:) {mustBeTextScalar} = ".*"
end

% Convert text inputs 2 strings 4 consistency
fileFilter = string(fileFilter);
modeTxt = string(options.mode);
parentPath = string(options.parentPath);
subFolders = cellstr(options.subFolders);
folderFilter = string(options.folderFilter);

if modeTxt == "folder"
    % Select folders using helper function
    chosenDirs = uigetfolder(parentPath, folderFilter, ...
        "Select Folders", "MultiSelect", "on");
    
    if isequal(chosenDirs, 0)
        error("myGetFiles:userCanceled", "Canceled by user.");
    end
    chosenDirs = string(chosenDirs);
    
    % Create full search pattern avoiding loops and massive overhead
    dirs2search = fullfile(chosenDirs, subFolders{:}, fileFilter);
    
    % Get all files exclusively across selected directories using arrayfun
    dirOut = arrayfun(@(x) dir(x), dirs2search, "UniformOutput", false);
    filesFound = vertcat(dirOut{:});
    
    if isempty(filesFound)
        error("myGetFiles:noFiles", "No valid files.");
    end
    
    % Filter out directories
    filesFound = filesFound(~[filesFound.isdir]);
    
    % Sort folders alphanumerically using helper function
    [~, sortInd] = natsort(string({filesFound.folder}));
    fileNames = string({filesFound(sortInd).name})';
    fileFolders = string({filesFound(sortInd).folder})';
    
else
    % path4ui = fullfile(parentPath, subFolders{:}, fileFilter);
    % generate the full filter
    pathPattern=fullfile(parentPath,subFolders{:},fileFilter);
    [~,~,fileExt]=fileparts(fileFilter);
    extFilter=strcat("*",fileExt);
    % Generate path 4 UI dialog
    path4ui=fullfile(parentPath,subFolders{:},extFilter);
    
    % Select files via UI
    [namesTemp, foldersTemp] = uigetfile(path4ui, "Select Files", ...
        pathPattern, "MultiSelect", "on");
    
    if isequal(namesTemp, 0)
        error("myGetFiles:userCanceled", "Canceled by user.");
    end
    
    % Handle both single (char) and multiple (cell) selections safely
    fileNames = string(namesTemp)';
    numFiles = numel(fileNames);
    fileFolders = repmat(string(foldersTemp), numFiles, 1);
end
if isempty(fileNames),error('No valid files. ');end
end


%% old method without helper functions
% if isSelectFolder % select folders and process all files inside each folder
%     % Select the data folder using Regular Expression (regex/regexp)
%     patientIds = uigetfolder(parentPath,'^[cg]\d+\w*','','MultiSelect','on');
%     % if no file selected
%     if isequal(patientIds,0), error('Canceled by user. ');end
%     patientIds=string(patientIds);
%     % traverse all possible vol files
%     dcmPattern=fullfile(parentPath,'*','vol2dicom',dcmNameFilter);
%     dcmDirAll=dir(dcmPattern);
%     % remove directionary paths
%     dcmDirAll=dcmDirAll(~[dcmDirAll.isdir]);
%     % select only the chosen patient IDs
%     dcmDir=fullfile(patientIds,'vol2dicom');
%     dcmDirChosen=ismember({dcmDirAll.folder},dcmDir);
%     dcmDirAll=dcmDirAll(dcmDirChosen);
%     % Natural-order / alphanumeric sort
%     [~,dcmInd]=natsort({dcmDirAll.folder});
%     % export the vol file name and folder path
%     dcmNames=string({dcmDirAll(dcmInd).name});
%     dcmFolder=string({dcmDirAll(dcmInd).folder});
% else % select .vol files
%     pathPattern=fullfile(parentPath,'vol2dicom',dcmNameFilter);
%     path4files=fullfile(parentPath,'vol2dicom','*.dcm');
%     % Select the files
%     [dcmNames, dcmFolder] = uigetfile(path4files,'',pathPattern,...
%         'MultiSelect','on');
%     % if no file selected
%     if isequal(dcmNames,0), error('Canceled by user. ');end
%     dcmNames=string(dcmNames);
%     dcmFolder=string(dcmFolder);
%     % generate folder pather for each vol file
%     dcmFolder=repmat(dcmFolder,length(dcmNames),1);
% end
% if isempty(dcmNames),error('No valid DICOM files. ');end