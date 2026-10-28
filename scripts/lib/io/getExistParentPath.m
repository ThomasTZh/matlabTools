function pathParent = getExistParentPath(path2dir)
% getExistParentPath Finds deepest existing parent directory.
%
% Description:
%   This function traverses upward from a given directory path until it
%   encounters a directory that currently exists on the file system.
%
% Syntax:
%   pathParent = getExistParentPath(path2dir)
%
% Input Arguments:
%   path2dir - Target path (character vector or scalar string).
%
% Output Arguments:
%   pathParent - Deepest existing parent path (matches input type).
%
% Examples:
%   p = getExistParentPath('C:\Windows\System32\FakeDir');
%
% Program by TZ 06 July 2026
%

% Check input arguments
narginchk(1, 1);

% Validate input to ensure it is a valid scalar text
validateattributes(path2dir, {'char', 'string'}, {'scalartext'}, ...
    'getExistParentPath', 'path2dir');

% Preserve input data type for final output casting
flag4char = ischar(path2dir);

% Convert to string for highly efficient manipulation
path4parent = string(path2dir);

% Standardize slashes to system default to handle mixed-slash inputs
path4parent = replace(path4parent, {'/', '\'}, filesep);

% Traverse upward until an existing directory is found
while ~exist(path4parent, 'dir')
    % Strip trailing separators; 'strip' operates optimally on string arrays
    path4parent = strip(path4parent, 'right', filesep);

    % Extract parent path using native fileparts for speed
    path4next = fileparts(path4parent);

    % Check for root boundary to prevent infinite loops
    if path4parent == path4next
        error('getExistParentPath:rootReached', ...
            'Traversed to root but no existing directory found.');
    end
    
    % Update parent path tracker
    path4parent = path4next;
end

% Cast output back to original data type
if flag4char
    pathParent = char(path4parent);
else
    pathParent = path4parent;
end
end