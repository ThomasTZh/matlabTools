function [mean_gmsd, std_gmsd] = calGmsd(multi_matrix, ref_matrix)
% calGmsd calculates the Gradient Magnitude Similarity Deviation (GMSD)
% for multi-dimensional matrices treated as stacked images.
%
% Inputs:
% multi_matrix: N-dimensional matrix containing distorted images
% ref_matrix: N-dimensional matrix containing reference images
% 
% Outputs:
% mean_gmsd: Mean of the GMSD scores across all stacked images
% std_gmsd: Standard deviation of the GMSD scores across all stacked images

% Verify that both input matrices have identical dimensions
if ~isequal(size(multi_matrix), size(ref_matrix))
    error('Dimensions of multi_matrix and ref_matrix must be identical.');
end

% ensure inputs are 0 to 255 range
multi_matrix=mat2grayOmitNan(double(multi_matrix))*255;
ref_matrix=mat2grayOmitNan(double(ref_matrix))*255;

sz = size(multi_matrix);

% Calculate total number of images based on dimensions
if length(sz) < 3
    num_images = 1;
else
    num_images = prod(sz(3:end));
end

% Reshape to 3D arrays where the 3rd dimension represents the stacked images
multi_reshaped = reshape(multi_matrix, sz(1), sz(2), num_images);
ref_reshaped = reshape(ref_matrix, sz(1), sz(2), num_images);

scores = zeros(num_images, 1);

% Iterate over all images to compute individual GMSD scores
for i = 1:num_images
    % Convert image slices to double precision for the helper function
    Y1 = double(ref_reshaped(:, :, i));
    Y2 = double(multi_reshaped(:, :, i));
    
    % Calculate GMSD score utilizing the uploaded helper function
    [score, ~] = GMSD(Y1, Y2);
    scores(i) = score;
end

% Compute the final statistics
mean_gmsd = mean(scores);

if num_images > 1
    std_gmsd = std(scores);
else
    std_gmsd = 0;
end

end