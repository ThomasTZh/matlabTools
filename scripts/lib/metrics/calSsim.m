function [mean2out, std2out] = calSsim(data4test, data4ref, type4ssim)
%calSsim Calculate mean and std of SSIM for stacked images.
%
% Description:
%   [mean2out, std2out] = calSsim(data4test, data4ref) 
%   computes the mean and standard deviation of the Structural 
%   Similarity (SSIM) index across a multi-dimensional matrix.
%   The first two dimensions are spatial; others are stacked images.
%
% Syntax:
%   [mean2out, std2out] = calSsim(data4test, data4ref)
%   [mean2out, std2out] = calSsim(data4test, data4ref, type4ssim)
%
% Input Arguments:
%   data4test - Multi-dimensional numeric array (test data).
%   data4ref  - Multi-dimensional numeric array (reference data).
%               Must be the same size and class as data4test.
%   type4ssim - (Optional) String or char array specifying the method.
%               Valid choices are 'ssim' (default) or 'multissim'.
%
% Output Arguments:
%   mean2out  - Mean of the SSIM scores across all stacked images.
%   std2out   - Standard deviation of the SSIM scores.
%
% Examples:
%   img4ref = rand(256, 256, 10);
%   img4test = img4ref + 0.1 * randn(256, 256, 10);
%   [mSsim, sSsim] = calSsim(img4test, img4ref, 'multissim');

% 1. Check number of input arguments
narginchk(2, 3);

% 2. Assign default method if not provided by user
if nargin < 3
    type4ssim = 'ssim';
end

% 3. Validate input arrays and parameters
validateattributes(data4test, {'numeric'}, {'nonempty'}, ...
    'calculateStackedSsim', 'data4test', 1);
validateattributes(data4ref, {'numeric'}, ...
    {'nonempty', 'size', size(data4test)}, 'calSsim', 'data4ref', 2);
type4eval = validatestring(type4ssim, {'ssim', 'multissim'}, ...
    'calSsim', 'type4ssim', 3);

% 4. Determine dimensions and calculate total stacked images
sz4data = size(data4test);
if length(sz4data) < 3
    num2stack = 1;
else
    num2stack = prod(sz4data(3:end));
end

% 5. Reshape to 3D matrix to cleanly loop through stacked images
% This flattens arbitrary dimensions (e.g., 4D/5D) into the 3rd axis
data4test = reshape(data4test, sz4data(1), sz4data(2), num2stack);
data4ref = reshape(data4ref, sz4data(1), sz4data(2), num2stack);

% 6. Initialize output array for memory efficiency
scores4all = zeros(num2stack, 1);

% 7. Define function handle to avoid conditional branching in loop
if strcmpi(type4eval, 'ssim')
    func4eval = @ssim;
else
    func4eval = @multissim;
end

% 8. Iterate through 2D slices to calculate structural similarity
for idx4loop = 1:num2stack
    img4test = data4test(:, :, idx4loop);
    img4ref = data4ref(:, :, idx4loop);
    scores4all(idx4loop) = func4eval(img4test, img4ref);
end

% 9. Calculate final statistical metrics
mean2out = mean(scores4all);
if num2stack > 1
    std2out = std(scores4all);
else
    std2out = 0; % Ensures robust output for a single 2D matrix
end

end