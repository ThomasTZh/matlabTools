function data = lr4mControlData(name, value, limits, options)
%lr4mControlData - Build state exchanged with an HTML slider control
%   DATA = lr4mControlData(NAME,VALUE,LIMITS) creates adjustment-slider
%   state with one-decimal steps and a zero-reset button.
%
%   DATA = lr4mControlData(...,Name=VALUE) customizes Step, Enabled,
%   ShowReset, ShowValue, ResetValue, and the JavaScript event Phase.
%
%   Replacing the whole payload, instead of mutating fields piecemeal,
%   keeps MATLAB and JavaScript rendering deterministic.

arguments
    name
    value
    limits (1,2) double
    options.Step (1,1) double = 0.1
    options.Enabled (1,1) logical = true
    options.ShowReset (1,1) logical = true
    options.ShowValue (1,1) logical = true
    options.ResetValue (1,1) double = 0
    options.Phase = "matlab"
end

data = struct(Name=char(name), Value=double(value), ...
    Minimum=limits(1), Maximum=limits(2), Step=options.Step, ...
    Enabled=options.Enabled, ShowReset=options.ShowReset, ...
    ShowValue=options.ShowValue, ResetValue=options.ResetValue, ...
    Phase=char(options.Phase));
end
