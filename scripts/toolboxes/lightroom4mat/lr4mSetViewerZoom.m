function lr4mSetViewerZoom(viewer, mode, imageSize)
%lr4mSetViewerZoom - Set a viewer2d to fitted or one-to-one magnification
%   lr4mSetViewerZoom(VIEWER,"fit",IMAGESIZE) centers the image and fits it
%   within VIEWER. lr4mSetViewerZoom(VIEWER,"actual",IMAGESIZE) centers the
%   image and sets one image pixel to one screen-layout pixel (100%).
%
%   viewer2d.CameraZoom is not a percentage in MATLAB R2024b. At unit zoom,
%   the visible vertical world extent equals the camera-to-target distance.
%   For imageshow's default pixel coordinates, the displayed scale is
%
%       viewportHeight / cameraDistance * CameraZoom.
%
%   Consequently, cameraDistance / viewportHeight is the exact zoom that
%   makes one image-coordinate unit occupy one screen-layout pixel.

mode = string(validatestring(mode, ["fit", "actual"], ...
    mfilename, "mode"));

% Flush pending image or layout changes before reading the camera. The
% center is then restored explicitly: in R2024b, RESET can leave a manual
% CameraZoom value latched and prevent the next value from being rendered.
drawnow;
cameraPosition = double(viewer.CameraPosition);
cameraTarget = double(viewer.CameraTarget);
cameraOffset = cameraPosition - cameraTarget;
cameraDistance = norm(cameraOffset);
viewportSize = double(viewer.InnerPosition(3:4));

centerTarget = cameraTarget;
centerTarget(1:2) = double([imageSize(2) imageSize(1)] + 1) / 2;
viewer.CameraTarget = centerTarget;
viewer.CameraPosition = centerTarget + cameraOffset;

if mode == "actual"
    displayScale = 1;
else
    % A small inset matches viewer2d's fitted presentation and keeps the
    % first and last pixel rows visibly inside the viewport. Computing the
    % zoom also avoids an R2024b behavior where RESET leaves a previously
    % manual CameraZoom value unchanged.
    fitInset = 14;
    availableSize = max(1, viewportSize - 2 * fitInset);
    imageExtent = double([imageSize(2) imageSize(1)]);
    displayScale = min(availableSize ./ imageExtent);
end

if isfinite(cameraDistance) && cameraDistance > 0 && ...
        all(isfinite(viewportSize)) && all(viewportSize > 0) && ...
        isfinite(displayScale) && displayScale > 0
    viewer.CameraZoom = displayScale * cameraDistance / viewportSize(2);
end
end
