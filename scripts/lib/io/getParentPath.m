function path4out = getParentPath(path4in)
% getParentPath Extract parent directory for string, char, or cell inputs.
%
% Description:
%   This function extracts the parent directory from the provided path.
%   Trailing separators are removed. If the input is already a root
%   directory (e.g., 'C:\' or '/'), it returns the root and warns.
%
% Syntax:
%   path4out = getParentPath(path4in)
%
% Input Arguments:
%   path4in - Char vector, string array, or cell array of char vectors.
%
% Output Arguments:
%   path4out - Parent directory path, matching the input data type.
%
% Example:
%   path4test = {'/dir1/dir2/', 'D:\'};
%   p = getParentPath(path4test);
%
% Program by TZ 18 Feb 2026
%

% Validate broad input class
validateattributes(path4in, {'char', 'string', 'cell'}, {}, ...
    'getParentPath', 'path4in');

% Identify original type to ensure output matches input class
flag4char = ischar(path4in);
flag4cell = iscellstr(path4in);

% Strict validation for cell arrays
if iscell(path4in) && ~flag4cell
    error('getParentPath:InvalidCell', ...
        'Cell array inputs must contain only character vectors.');
end

% Cast to string array for vectorized, low-overhead processing
path4str = string(path4in);

% Standardize slashes to system default to handle mixed-slash inputs
path4str = replace(path4str, {'/', '\'}, filesep);

% Identify root paths by checking if the path is its own parent
path4check = fileparts(path4str);
idx4root = (path4check == path4str) & (path4str ~= "");

% Handle Windows drive letters without slashes (e.g., "D:") as roots
idx4drive = strlength(path4str) == 2 & endsWith(path4str, ':');
idx4root = idx4root | idx4drive;

% Trigger warning if any root directories are detected
if any(idx4root, 'all')
    warning('getParentPath:RootInput', ...
        'Input contains root folder(s). Output remains the root.');
end

% Initialize clean path and parent path arrays
path4clean = path4str;
path4parent = path4str;

% Strip trailing separators only for non-root directories
idx4notRoot = ~idx4root;
path4clean(idx4notRoot) = strip(path4str(idx4notRoot), ...
    'right', filesep);

% Extract parent path for non-root directories
path4parent(idx4notRoot) = fileparts(path4clean(idx4notRoot));

% Resolve empty outputs when inputs were standalone folders
idx4empty = (path4parent == "") & (path4clean ~= "") & idx4notRoot;
path4parent(idx4empty) = ".";

% Cast the processed data back to its original class
if flag4char
    path4out = char(path4parent);
elseif flag4cell
    path4out = cellstr(path4parent);
else
    path4out = path4parent; % Data remains a string array
end

end