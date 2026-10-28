function value = lr4mQuantizeAdjustment(value)
%lr4mQuantizeAdjustment - Round a control value to one decimal place
%   VALUE = lr4mQuantizeAdjustment(VALUE) applies the precision shared by
%   name-value inputs, GUI controls, and generated command strings.

value = round(double(value) * 10) / 10;

% MATLAB can retain a signed negative zero after floating-point rounding.
% Canonicalizing it keeps command strings and equality checks predictable.
if value == 0
    value = 0;
end
end
