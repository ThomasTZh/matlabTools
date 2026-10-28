function [width, locs] = calFWHM(varargin)
% CALFWHM Calculate Full Width at Half Maximum (FWHM) of a signal.
%   WIDTH = CALFWHM(Y) calculates the Full Width at Half Maximum of the 
%   data vector Y. The function assumes the indices 1:length(Y) as the 
%   independent variable.
%
%   WIDTH = CALFWHM(X, Y) calculates the FWHM of Y with respect to the 
%   independent variable X.
%
%   [WIDTH, LOCS] = CALFWHM(...) also returns the specific locations (x-values)
%   where the signal intercepts the half-maximum level. LOCS is a 1x2 vector 
%   [left_crossing, right_crossing].
% 
%   WIDTH = CALWIDTH(___, 'Mode', 'Prominence') calculates width at 
%   half-prominence, which is more robust for signals with offsets.
%
%   METHOD:
%   The function finds the global maximum of the signal and calculates the
%   half-maximum level as: (Max - Min) / 2 + Min.
%   It then searches for the zero-crossings of (Y - Level) immediately 
%   surrounding the peak index. Linear interpolation is used to determine 
%   the precise locations between data points.
% 
%   MODES:
%       'FWHM' (Default):
%           Baseline = Global Minimum of the signal.
%           Level = (Max - GlobalMin) / 2 + GlobalMin.
%           Good for: Symmetric peaks on a flat zero baseline.
%       'Prominence':
%           Baseline = Higher of the two interval minima (Left/Right valleys).
%           Level = Max - (Prominence / 2).
%           Good for: Peaks on steps, slanted baselines, or offsets.
%
%   EXAMPLE 1: Simple Gaussian
%       x = linspace(-10, 10, 100);
%       y = exp(-x.^2 / (2*2^2)); % Sigma=2
%       w = calFWHM(x, y);
%       fprintf('Calculated FWHM: %.4f (Expected: %.4f)\n', w, 2.3548*2);
%
%   EXAMPLE 2: Noisy signal with offset
%       x = 0:0.1:20;
%       y = 10 + 5*sin(x); % Peak at 15, Min at 5, Half-max at 10
%       [w, locs] = calFWHM(x, y);
%
%   See also MAX, MIN, INTERP1.

    % --- Input Parsing ---
    p = inputParser;
    addOptional(p, 'x_or_y', []);
    addOptional(p, 'y_opt', []);
    addParameter(p, 'Mode', 'FWHM',...
        @(s) any(validatestring(s, {'FWHM', 'Prominence'})));
    parse(p, varargin{:});
    
    % Handle X/Y assignment
    if isempty(p.Results.y_opt)
        y = p.Results.x_or_y;
        x = 1:numel(y);
    else
        x = p.Results.x_or_y;
        y = p.Results.y_opt;
    end
    
    mode = p.Results.Mode;
    x = x(:); y = y(:);
    
    % --- Clean NaNs (Robustness) ---
    mask = ~isnan(x) & ~isnan(y);
    x = x(mask); y = y(mask);
    
    if length(y) < 3
        width = NaN; locs = [NaN NaN]; return; 
    end

    % --- 1. Find Local Main Peak ---
    isPeak = islocalmax(y, 'FlatSelection', 'center');
    if ~any(isPeak)
        % No peaks found (Signal might be a ramp, flat, or V-shape)
        width = NaN; locs = [NaN NaN];
        return;
    end
    
    % Extract the values and indices of valid peaks
    valid_peaks_y = y(isPeak);
    valid_peaks_idx = find(isPeak);
    
    % Select the HIGHEST peak among the valid local maxima
    [y_max, relative_idx] = max(valid_peaks_y);
    max_idx = valid_peaks_idx(relative_idx);

    % [y_max, max_idx] = max(y);
    
    % --- 2. Determine Calculation Level ---
    if strcmpi(mode, 'FWHM')
        % Standard FWHM: Relative to global minimum
        y_min = min(y);
        level = (y_max - y_min) / 2 + y_min;
        
    else % Mode: Prominence
        % Calculate Prominence Baseline manually for the Global Max
        % The baseline is the HIGHER of the minima on either side of the peak.
        
        % Left region (start to peak)
        if max_idx > 1
            min_left = min(y(1:max_idx));
        else
            min_left = y_max; % Fallback if peak is at edge
        end
        
        % Right region (peak to end)
        if max_idx < length(y)
            min_right = min(y(max_idx:end));
        else
            min_right = y_max;
        end
        
        % The 'Base' for prominence is the higher of the two valleys
        % This effectively ignores the deeper valley if the peak is on a step.
        prominence_base = max(min_left, min_right);
        
        prominence = y_max - prominence_base;
        level = y_max - (prominence / 2);
    end
    
    % --- 3. Find Crossings (Same interpolation logic) ---
    if 0
        % Search Left
        idx_left = find(y(1:max_idx) < level, 1, 'last');
        % Search Right
        idx_right_rel = find(y(max_idx:end) < level, 1, 'first');
    else
        % Search Left
        idx_left = find(y(1:max_idx) >= level, 1, 'first')-1;
        if idx_left<1,idx_left=[];end
        % Search Right
        idx_right_rel = find(y(max_idx:end) >= level, 1, 'last')+1;
        if idx_right_rel>numel(y)-max_idx+1,idx_right_rel=[];end
    end
    
    isClipped = false;
    if isempty(idx_left)
        idx_left = 1;
        isClipped = true;
    end
    
    if ~isempty(idx_right_rel)
        idx_right = idx_right_rel + max_idx - 1;
    else
        idx_right = numel(y);
        isClipped = true;
    end
    if isClipped
        warning('calFWHM:clipped', ...
            ['The half-%s level is not crossed on one or two sides of the ' ...
             'peak; WIDTH was estimated.'], lower(char(mode)));
    end
    
    % Interpolate Left
    x1 = x(idx_left);   y1 = y(idx_left);
    x2 = x(idx_left+1); y2 = y(idx_left+1);
    loc_left = x1 + (level - y1) * (x2 - x1) / (y2 - y1);
    
    % Interpolate Right
    x3 = x(idx_right-1); y3 = y(idx_right-1);
    x4 = x(idx_right);   y4 = y(idx_right);
    loc_right = x3 + (level - y3) * (x4 - x3) / (y4 - y3);
    
    width = loc_right - loc_left;
    locs = [loc_left, loc_right];
end