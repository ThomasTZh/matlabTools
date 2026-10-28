function val4choice = uiChoose(text4prompt, list4options)
%UICHOOSE Create a resolution-independent, dynamically scaled modal dialog.
%
% Description:
%   val4choice = uiChoose(text4prompt, list4options) creates a modal UI
%   figure where all dimensions (width, height, fonts, padding) are 
%   calculated strictly as mathematical ratios of the screen resolution.
%
% Syntax:
%   val4choice = uiChoose(text4prompt, list4options)
%
% Input Arguments:
%   text4prompt  - Text to display as a prompt (char vector or string).
%   list4options - Cell array of char vectors or string array for buttons.
%
% Output Arguments:
%   val4choice   - The selected option as a character array. Returns
%                  an empty character array if the window is closed.
%
% Program by TZ 01 July 2026
%


% Validate inputs
narginchk(2, 2);
validateattributes(text4prompt, {'char', 'string'}, {'scalartext'}, ...
    mfilename, 'text4prompt', 1);
validateattributes(list4options, {'cell', 'string'}, {'vector'}, ...
    mfilename, 'list4options', 2);

list4options = cellstr(list4options);
num4btns = numel(list4options);
val4choice = '';

% --- Resolution-Dependent Ratio Calculations ---
size4main = get(groot, 'ScreenSize');
w4screen = size4main(3);
h4screen = size4main(4);

% Vertical ratios (based on 1080p baseline)
size4font = max(10, round(h4screen * 0.013)); % ~14pt at 1080p
h4btn = round(h4screen * 0.037);              % ~40px at 1080p
h4gap = round(h4screen * 0.009);              % ~10px at 1080p
h4pad = round(h4screen * 0.074);              % ~80px margin/padding total

% Horizontal ratios (based on 1920p baseline)
w4char = w4screen * 0.0052;                   % ~10px per char at 1920p
w4pad = w4screen * 0.01;                      % ~19px width padding
w4min = w4screen * 0.1;                       % ~192px minimum width

% 1. Calculate dynamic height
height4fig = h4pad + (num4btns * h4btn) + ((num4btns - 1) * h4gap);

% 2. Calculate dynamic width
len4prompt = strlength(text4prompt);
len4opts = max(strlength(list4options));
max4chars = max([len4prompt, len4opts]);
width4fig = max(w4min, max4chars * w4char + w4pad);

% 3. Calculate primary monitor center position
x4pos = (w4screen - width4fig) / 2;
y4pos = (h4screen - height4fig) / 2;
pos4fig = [x4pos, y4pos, width4fig, height4fig];

% Create modal UI figure
fig4ui = uifigure('Name', 'Select Option', ...
    'Position', pos4fig, ...
    'WindowStyle', 'modal');
fig4ui.CloseRequestFcn = @(src, event) cb4close();

% Create grid with dynamic, ratio-based row heights
grid4ui = uigridlayout(fig4ui, [num4btns + 1, 1]);
grid4ui.RowHeight = [{'1x'}, repmat({h4btn}, 1, num4btns)];
grid4ui.RowSpacing = h4gap;
grid4ui.ColumnWidth = {'1x'};

% Add prompt text
lbl4prompt = uilabel(grid4ui);
lbl4prompt.Text = text4prompt;
lbl4prompt.HorizontalAlignment = 'center';
lbl4prompt.FontSize = size4font;

% Create buttons dynamically
for idx4btn = 1:num4btns
    btn4opt = uibutton(grid4ui, 'Text', list4options{idx4btn});
    btn4opt.FontSize = size4font;
    btn4opt.ButtonPushedFcn = ...
        @(btn, event) cb4btn(list4options{idx4btn});
end

uiwait(fig4ui);

    % --- Nested Callback Functions ---
    function cb4btn(val4sel)
        val4choice = val4sel;
        uiresume(fig4ui);
        delete(fig4ui);
    end

    function cb4close()
        val4choice = '';
        uiresume(fig4ui);
        delete(fig4ui);
    end
end