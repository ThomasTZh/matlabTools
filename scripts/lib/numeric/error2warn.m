function error2warn(ME)
%ERROR2WARN Display an exception as a warning with clickable stack links.
%
%   error2warn(ME) displays the error message and stack trace from the
%   MException ME. Stack entries are clickable and open the corresponding
%   file at the relevant line in the MATLAB Editor.

arguments
    ME (1,1) MException
end

fprintf(2, 'Warning: %s\n', ME.message);

for iME = 1:numel(ME.stack)
    fileName = ME.stack(iME).file;
    functionName = ME.stack(iME).name;
    lineNumber = ME.stack(iME).line;

    % Escape single quotes for use inside the MATLAB hyperlink command.
    linkFileName = strrep(fileName, '''', '''''');

    fprintf(2, ...
        ['> In <a href="matlab:open(''%s'')">%s</a> ' ...
        '(<a href="matlab:opentoline(''%s'',%d)">line %d</a>)\n'], ...
        linkFileName, functionName, ...
        linkFileName, lineNumber, lineNumber);
end
end