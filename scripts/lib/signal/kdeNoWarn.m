function kdeOut = kdeNoWarn(inData, evalPts, varargin)
%KDENOWARN Computes ksdensity robustly by handling convergence failures.
%
% Description:
%   Evaluates kernel density estimates using ksdensity within a robust 
%   try-catch mechanism. If vectorized evaluation fails, it automatically 
%   falls back to element-wise evaluation, assigning NaN to failed points.
%
% Syntax:
%   kdeOut = kdeNoWarn(inData, evalPts)
%   kdeOut = kdeNoWarn(inData, evalPts, Name, Value)
%
% Input Arguments:
%   inData  - Numeric vector containing the sample data.
%   evalPts - Numeric vector of points to evaluate the density or icdf.
%   varargin- Optional Name-Value pairs accepted by ksdensity.
%
% Output Arguments:
%   kdeOut  - Vector of evaluated results, same size as evalPts.
%
% Examples:
%   inData = randn(100, 1);
%   evalPts = [0.1, 0.5, 0.9];
%   kdeOut = kdeNoWarn(inData, evalPts, 'Function', 'icdf');

% Validate primary inputs
validateattributes(inData, {'numeric'}, {'vector', 'nonempty', ...
    'real'}, 'kdeNoWarn', 'inData', 1);
validateattributes(evalPts, {'numeric'}, {'vector', 'real', ...
    'nonnan'}, 'kdeNoWarn', 'evalPts', 2);

% Define warning ID to catch (customizable based on specific needs)
id4warn = 'stats:ksdensity:NoConvergence';

% Store original warning state and set as error to trigger catch block
warnState = warning('query', id4warn);
warning('error', id4warn);

numPts = length(evalPts);
kdeOut = nan(1, numPts);

try
    % Attempt efficient vectorized calculation
    kdeOut = ksdensity(inData, evalPts, varargin{:});
catch
    % Fallback 2 robust element-wise execution if vectorized fails
    for idx4loop = 1:numPts
        try
            kdeOut(idx4loop) = ksdensity(inData, evalPts(idx4loop),varargin{:});
        catch
            % Assign NaN for unconverged points
            kdeOut(idx4loop) = NaN;
        end
    end
end

% Restore original warning state 2 prevent workspace pollution
warning(warnState);

end