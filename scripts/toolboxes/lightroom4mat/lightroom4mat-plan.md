# Implementation Notes: lightroom4mat

The source is an ordinary MATLAB folder rather than a `+package` namespace,
so the public call remains `lightroom4mat(...)`.

- `lightroom4mat.m` is the thin public API and help entry point.
- `lr4mPrepareRequest.m` owns cross-option validation, color resolution,
  dimension normalization, aliases, and effective grayscale parameters.
- `lr4mProcessArray.m` enumerates independent N-D processing blocks, while
  `lr4mProcessBlock.m` owns normalization and class/range restoration.
- `lr4mAdjustLuminance.m`, `lr4mProcessRGBBlock.m`, and
  `lr4mApplyDehaze.m` contain the three cohesive algorithm stages.
- Small `lr4m*` numeric helpers provide Gaussian filtering, transfer
  functions, smooth masks, clamping, and shared precision rules.
- `lr4mRunEditor.m` owns modal state and callbacks;
  `lr4mCreateEditorUI.m` owns component construction and styling.
- `lr4mControlData.m` and `lr4mExtractDisplaySlice.m` isolate the MATLAB/HTML
  state contract and N-D preview indexing respectively.
- `lr4mControl.html` supplies the sage, tick-free slider rows used for both
  adjustments and slice navigation. Each adjustment row includes its own
  zero-reset button and a borderless one-decimal value editor.
- `lr4mViewerToolbar.html` provides the compact Fit and Actual Size pill
  beside viewer2d's percentage badge, using the same translucent light
  treatment. `lr4mSetViewerZoom.m` converts the R2024b camera model to an
  exact 100% pixel scale and computes a centered, padded fit after any prior
  zoom state. The fixed-height adjustment grid owns vertical scrolling when
  the window is shorter than its controls.
- `lr4mBuildCommand.m` owns canonical command generation.
- `lr4mAdjustmentNames.m` provides the shared control order.

The processing model separates global tone, perceptual tonal-range controls,
local detail scales, haze transmission, chroma, and white balance. Adjustment
values are quantized to 0.1. GUI Done returns a non-GUI command without
processing the complete array. The algorithms are deterministic, documented
approximations rather than Adobe or Google implementations. Tests remain
outside this folder under `tests/`.
