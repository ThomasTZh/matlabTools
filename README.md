# matlabTools

A personal MATLAB library for image, volume and signal processing, organised
by purpose. The code lives in the `scripts` folder of this repository.
First-party code is under `lib/` and `toolboxes/`; third-party packages are
under `external/` and are kept unmodified. Paths in this file are relative to
`scripts/` unless stated otherwise.

| Item | Count | Where |
|---|---|---|
| General-purpose functions | 42 in 8 categories | `lib/` |
| Toolboxes | 2 | `toolboxes/` |
| Third-party packages | 3 | `external/` |

## Quick start

```matlab
% Add the library to the path (once per MATLAB session)
addpath(genpath('<path to matlabTools>/scripts'))

% Help for any function
help calPsnr

% Example: filter a volume, then score it
vol = rand(128, 128, 16);
filtered = medfilt3sym4nan(vol);            % requires IPT
[mPsnr, sPsnr] = calPsnr(filtered, vol, 1);
[mNrmse, sNrmse] = calNrmse(filtered, vol);
```

`addpath(genpath(...))` covers `lib`, `toolboxes` and `external`.
Re-run it after adding a new subfolder, because `genpath` snapshots the path at
call time. The repository has no `startup.m`; create one that calls
`addpath(genpath(...))` if you want the path set automatically at start-up.

## Requirements

| Product | Needed by | Notes |
|---|---|---|
| MATLAB R2023a or later | whole library | `calEpi` uses the `omitmissing` option of `mean` and `std` (R2023a). `arguments` blocks in many functions require R2019b or later. |
| Image Processing Toolbox | 10 library functions, `GMSD`, `lightroom4mat` blur stage | `calSsim`, `calGmsd`, `calEpi`, `mat2grayOmitNan`, `mat2grayPrct`, `imflatfield4nan`, `otsuNoNan`, `medfilt2sym4nan`, `medfilt3sym4nan`, `imsharpen3` |
| Statistics and Machine Learning Toolbox | 4 library functions | `calHausdorffDist`, `mat2grayPrct`, `normPrctile`, `kdeNoWarn` |
| MATLAB R2020a or later | `savePdf` only | `exportgraphics` |
| MATLAB R2024b camera behaviour | `lightroom4mat` GUI zoom | `lr4mSetViewerZoom` is calibrated for the R2024b camera model |

No Signal Processing Toolbox, Parallel Computing Toolbox, MEX files or
compilation are required. `saveSvg` uses `print -dsvg`, so it works on older
releases than `savePdf`. `frameViewer3D` uses base MATLAB only.

## Repository layout

```text
matlabTools/
├─ README.md                  % this file
├─ CREDITS.md                 % third-party attributions and licences
├─ AGENTS.md                  % coding conventions for AI-assisted work
└─ scripts/                   % all MATLAB code
   ├─ lib/
   │  ├─ metrics/             % image quality and error metrics
   │  ├─ intensity/           % intensity, contrast and normalisation
   │  ├─ filtering/           % median filtering and sharpening
   │  ├─ segmentation/        % masking and coordinate conversion
   │  ├─ signal/              % peak width and density estimation
   │  ├─ numeric/             % small array and search helpers
   │  ├─ viz/                 % colormaps and figure annotations
   │  └─ io/                  % file, folder, dialog and export helpers
   ├─ toolboxes/
   │  ├─ frameViewer3D.m      % volume viewer with segmentation overlays
   │  └─ lightroom4mat/       % photo-style adjustments for numeric arrays
   └─ external/
      ├─ GMSD/                % GMSD image quality engine
      ├─ natsortfiles/        % natural-order sorting
      └─ zoomed_axes/         % nested zoom axes class
```

## Function reference

Each table gives the call form, a short description and the toolbox needed.
`base` means MATLAB only.

### Image quality metrics (`lib/metrics`)

| Function | Syntax | Description | Needs |
|---|---|---|---|
| `calMAE` | `mae = calMAE(vec1, vec2)` | Mean absolute error, NaN pairs excluded | base |
| `calNrmse` | `[meanNrmse, stdNrmse] = calNrmse(inputMat, refMat)` | NRMSE per 2-D slice, mean and spread | base |
| `calPsnr` | `[meanScore, stdScore] = calPsnr(testMat, refMat, peakVal)` | PSNR per slice, optional peak value | base |
| `calSsim` | `[mean2out, std2out] = calSsim(test, ref, type4ssim)` | SSIM or MS-SSIM per slice | IPT |
| `calGmsd` | `[meanGmsd, stdGmsd] = calGmsd(test, ref)` | GMSD per slice via the `GMSD` engine | IPT + GMSD |
| `calEpi` | `[epiMean, epiStd] = calEpi(fltMat, refMat)` | Edge preservation index from Laplacian correlation | IPT |
| `calHausdorffDist` | `hd = calHausdorffDist(line1, line2, ...)` | Robust percentile Hausdorff distance | Stats |

Stacked-image metrics treat dimensions 1 and 2 as the image and all later
dimensions as independent slices. They return the mean and standard deviation
across slices.

### Intensity, contrast and normalisation (`lib/intensity`)

| Function | Syntax | Description | Needs |
|---|---|---|---|
| `mat2grayOmitNan` | `I = mat2grayOmitNan(A, limits)` | `mat2gray` with NaN-aware automatic limits | IPT |
| `mat2grayPrct` | `I = mat2grayPrct(A, limits, nanflag)` | Scale between percentiles, clip to [0, 1] | IPT + Stats |
| `normPrctile` | `V = normPrctile(vol, dims, pLow, pHigh, subRatio)` | Percentile normalisation with optional subsampling | Stats |
| `rescale4dim` | `B = rescale4dim(A, range4out, dim4scale)` | Rescale along selected dimensions to a target range | base |
| `imflatfield4nan` | `out = imflatfield4nan(img, sigma)` | NaN-aware flat-field correction | IPT |
| `gray2rgb` | `rgb = gray2rgb(img, map4color)` | Colourise a grayscale image through a colormap | base |
| `otsuNoNan` | `[level, metric] = otsuNoNan(img)` | Otsu threshold ignoring NaN values | IPT |

### Filtering and sharpening (`lib/filtering`)

| Function | Syntax | Description | Needs |
|---|---|---|---|
| `medfilt2sym4nan` | `B = medfilt2sym4nan(A, [M N], padopt)` | 2-D median, symmetric padding, NaNs stay put | IPT |
| `medfilt3sym4nan` | `B = medfilt3sym4nan(A, [M N P], padopt)` | 3-D median, stops NaN blooming | IPT |
| `imsharpen3` | `out = imsharpen3(vol, Name=Value)` | 3-D unsharp mask, NaN and Inf preserved | IPT |

### Segmentation, masking and coordinates (`lib/segmentation`)

| Function | Syntax | Description | Needs |
|---|---|---|---|
| `segMask` | `mask = segMask(tempImg, segLine, setValue, maskDir)` | Mask a volume above or below a segmentation surface | base |
| `loc2coords` | `[x, y] = loc2coords(r0, c0, r, c)` | Matrix subscripts to Cartesian coordinates | base |
| `coords2loc` | `[r, c] = coords2loc(r0, c0, x, y)` | Cartesian coordinates to matrix subscripts | base |

### Signal, peaks and density (`lib/signal`)

| Function | Syntax | Description | Needs |
|---|---|---|---|
| `calFWHM` | `[width, locs] = calFWHM(Y)` or `calFWHM(X, Y, 'Mode', mode)` | Full width at half maximum or half prominence | base |
| `findPeaksWidthLocs` | `[pks, locs, w, p, wlocs] = findPeaksWidthLocs(Y, ...)` | `findpeaks` variant that also returns width crossings | base |
| `kdeNoWarn` | `kde = kdeNoWarn(data, evalPts, Name, Value)` | `ksdensity` wrapper with element-wise fallback | Stats |

### Numeric and array utilities (`lib/numeric`)

| Function | Syntax | Description | Needs |
|---|---|---|---|
| `antifix` | `y = antifix(x)` | Round away from zero, real or complex | base |
| `roundOdd` | `Y = roundOdd(X)` | Nearest odd integer | base |
| `rnz` | `r = rnz(A)` | Ratio of nonzero elements | base |
| `find4dim` | `idx = find4dim(inMat, searchDim, num2find, searchDir)` | First, last or mean nonzero index along dimensions | base |
| `findmax` | `[m, i] = findmax(x, pos, nanflag, dim)` | Maximum with plateau position choice | base |
| `summax` | `S = summax(A, n, dim, nanflag)` | Sum of the top n values | base |
| `meanmax` | `S = meanmax(A, n, dim, nanflag)` | Mean of the top n values | base |
| `error2warn` | `error2warn(ME)` | Print an exception as clickable warnings | base |

### Visualisation (`lib/viz`)

| Function | Syntax | Description | Needs |
|---|---|---|---|
| `addDopplerColormap` | `map = addDopplerColormap(fig, posCol, negCol, zeroCol, n)` | Symmetric diverging colormap for signed data | base |
| `scaleBar` | `[hLines, hText] = scaleBar(axialPx, lateralPx, loc2place, Name=Value)` | L-shaped scale bars with physical units | base |

### File, folder, dialogs and export (`lib/io`)

| Function | Syntax | Description | Needs |
|---|---|---|---|
| `myGetFiles` | `[names, folders] = myGetFiles(filter, Name=Value)` | Filtered file or folder selection dialog | base + natsort |
| `uigetfolder` | `sel = uigetfolder(startPath, regPattern, title, ...)` | Regex-filtered multi-select folder dialog | base + natsort |
| `uiChoose` | `val = uiChoose(prompt, options)` | Resolution-scaled modal choice dialog | base |
| `getParentPath` | `p = getParentPath(path)` | Parent directory, preserving input type | base |
| `getExistParentPath` | `p = getExistParentPath(path)` | Deepest existing ancestor of a path | base |
| `wrtdir` | `wrtdir(path)` | Create a directory, avoiding read-only errors | base |
| `saveTif` | `saveTif(img, folder, name, suffix, compression)` | Write a TIFF with suffix and compression | base |
| `savePdf` | `savePdf(folder, name, suffix, fig)` | Vector PDF export | R2020a+ |
| `saveSvg` | `saveSvg(folder, name, suffix, fig)` | SVG export with the same naming rules | base |

## Toolboxes (`toolboxes`)

### lightroom4mat

`lightroom4mat` applies photo-editor style adjustments to numeric arrays and
works on arbitrary N-D data by selecting the dimensions that form the image.

```matlab
B = lightroom4mat(A, [1 2], Contrast=3, Saturation=2);
[B, command] = lightroom4mat(A, [1 2], Exposure=0.5);
command = lightroom4mat(A, [1 2], GUI=true);   % modal editor
```

Supported adjustments run from -10 to 10 and are quantised to 0.1. The
processing pipeline is split into request validation, block enumeration,
normalisation and three algorithm stages. See `lightroom4mat-plan.md` inside
the folder for the module map and design notes. GUI mode needs the HTML assets
in the same folder, so keep the folder intact.

### frameViewer3D

`frameViewer3D` scrolls through the frames of a 3-D volume and overlays
segmentation lines on each frame. It needs base MATLAB only and returns the
figure handle, so call `uiwait` to make it modal.

```matlab
% Scroll through a volume with two moving segmentation lines
data = rand(100, 128, 50);
lines = repmat(50 * ones(128, 1), [1, 50, 2]) + 2 * randn(128, 50, 2);
hFig = frameViewer3D(data, lines);
uiwait(hFig);
```

## Third-party packages (`external`)

| Package | Author | Source | Licence | Used by |
|---|---|---|---|---|
| GMSD | Wufeng Xue, Lei Zhang, Xuanqin Mou, Alan C. Bovik | [PolyU distribution page](https://web.comp.polyu.edu.hk/cslzhang/IQA/GMSD/GMSD.htm); IEEE TIP 23(2):684-695, 2014 | None stated | `calGmsd` |
| natsortfiles | Stephen Cobeldick | [File Exchange 47434](https://uk.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort) | BSD 3-Clause, in `license.txt` | `myGetFiles`, `uigetfolder` |
| zoomed_axes | Caleb E. Thomas | [File Exchange 182602](https://uk.mathworks.com/matlabcentral/fileexchange/182602-zoomed-axes) | BSD 3-Clause, in `license.txt` | none |

Full citations, version notes and licence details are in `CREDITS.md`.

`findPeaksWidthLocs` under `lib/signal` is a modified copy of the MathWorks
`findpeaks` function and keeps the original copyright notice. Treat it as
third-party derived code when redistributing. See `CREDITS.md`.

## Conventions

- One public function or class per file, and the file name matches the
  function name.
- Every function carries MATLAB help text with syntax, inputs, outputs and
  examples. Use `help <name>`.
- NaN-aware variants are named with `4nan`, `NoNan` or `OmitNan`, for example
  `medfilt3sym4nan`, `otsuNoNan`, `mat2grayOmitNan`.
- A numeral in a name marks a dimension or expands "for": `find4dim`,
  `rescale4dim`, `imsharpen3`.
- Metric functions treat dimensions 1 and 2 as spatial and later dimensions as
  independent slices.
- Undefined results return NaN rather than silently returning a value, for
  example `calMAE` on all-NaN input or `calFWHM` without a crossing.
- Naming follows lower camel case for new code. Some older functions keep
  uppercase arguments such as `X`, `A` or `S` to mirror MATLAB built-ins.

## Known issues and limitations

- `calEpi` swaps the `fltMat` and `refMat` labels in its validation calls and
  in the two `double` casts. The swap is consistent, so the correlation is
  numerically unchanged, but error messages name the wrong argument.
- Error identifiers and help text drift from current names in a few places:
  `calculateMAE` in `calMAE`, `calcPsnr4ndMatrix` in `calPsnr`,
  `calculateStackedSsim` in `calSsim`, `CALWIDTH` in the `calFWHM` help text,
  and snake_case variables in `calGmsd`.
- Duplication worth consolidating: `summax` and `meanmax` share one skeleton,
  as do `medfilt2sym4nan` and `medfilt3sym4nan`, and `savePdf` and `saveSvg`.
- Two peak-width routes exist: `findPeaksWidthLocs` (MathWorks derived) and
  `calFWHM` (independent). Pick one as canonical before relying on them
  interchangeably.
- No automated test suite is included.
- `GMSD` has no licence statement from its authors, so it is included with
  attribution only. Check with the authors before redistributing it elsewhere.

## Adding a new function

1. Put the file in the `lib` subfolder that matches its purpose. Create a new
   subfolder only if no category fits. Standalone tools go in `toolboxes/`.
2. Include help text and input validation, and keep lines within 80 columns.
3. Re-run `addpath(genpath('<path to matlabTools>/scripts'))` so the new
   subfolder is picked up.
4. Add a row to the relevant table in this README.

## Compatibility

The release floors above come from the documented functions and syntax used in
the code. The library has not been tested across every MATLAB release, so
verify behaviour on the release you deploy. `AGENTS.md` in the repository root
describes the coding and documentation conventions this library follows.
