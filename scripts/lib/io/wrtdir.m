function wrtdir(path2dir)
% wrtdir Create directory and avoid read-only state errors.
%
% Description:
%   This function safely creates a new directory. It navigates to 
%   the deepest existing parent directory before creation to bypass 
%   specific MATLAB read-only or network drive permission errors.
%
% Syntax:
%   wrtdir(path2dir)
%
% Input Arguments:
%   path2dir - Char vector or string scalar specifying target path.
%
% Output Arguments:
%   None.
%
% Examples:
%   wrtdir('C:\newFolder\subFolder');
%
% Program by TZ 06 July 2026
%

% Validate input attributes to ensure valid text format
validateattributes(path2dir, {'char', 'string'}, ...
    {'scalartext', 'nonempty'}, 'wrtdir', 'path2dir');

% Return immediately if the directory already exists
if exist(path2dir, 'dir')
    return;
end

% Find the deepest existing parent directory using the helper
path4parent = getExistParentPath(path2dir);

% Store the current working directory to restore later
path4pwd = pwd;

% Use onCleanup to guarantee the original path is restored safely
clean4pwd = onCleanup(@() cd(path4pwd));

% Navigate to existing parent to force file system refresh
cd(path4parent);

% Execute directory creation
mkdir(path2dir);

end