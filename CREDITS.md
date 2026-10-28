# Credits and third-party notices

This repository bundles third-party MATLAB code under `scripts/external` and
contains one file derived from a MathWorks function. Bundled files are
unmodified and keep their original headers, and each licence is reproduced
beside the code. First-party code lives in `lib/` and `toolboxes/`.

## Bundled packages

### Zoomed Axes (`zoomed_axes`)

| Item | Detail |
|---|---|
| Author | Caleb E. Thomas |
| Source | MATLAB File Exchange 182602, [Zoomed Axes](https://uk.mathworks.com/matlabcentral/fileexchange/182602-zoomed-axes) |
| Upstream repository | [thom7660/matlab_zoomed_axes](https://github.com/thom7660/matlab_zoomed_axes) |
| Licence | BSD 3-Clause, Copyright 2025 Caleb E. Thomas |
| Licence file | `scripts/external/zoomed_axes/license.txt` |
| Bundled version | File Exchange release 1.0.1.0; the upstream repository may be newer |
| Used by | Nothing in this repository; provided as an interactive plotting tool |

### Natural-Order Filename Sort (`natsort`, `natsortfiles`)

| Item | Detail |
|---|---|
| Author | Stephen Cobeldick |
| Source | MATLAB File Exchange 47434, [Natural-Order Filename Sort](https://uk.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort) |
| Licence | BSD 3-Clause, Copyright (c) 2026 Stephen Cobeldick |
| Licence file | `scripts/external/natsortfiles/license.txt` |
| Files | `natsort.m`, `natsortfiles.m`, documentation and tests |
| Used by | `myGetFiles`, `uigetfolder` |

### Gradient Magnitude Similarity Deviation (`GMSD`)

| Item | Detail |
|---|---|
| Authors | Wufeng Xue, Lei Zhang, Xuanqin Mou, Alan C. Bovik |
| Code source | Authors' distribution page, [GMSD at PolyU](https://web.comp.polyu.edu.hk/cslzhang/IQA/GMSD/GMSD.htm) |
| Licence | None stated on the distribution page |
| File | `scripts/external/GMSD/GMSD.m` |
| Used by | `calGmsd` |

Reference:

> W. Xue, L. Zhang, X. Mou, and A. C. Bovik, "Gradient Magnitude Similarity
> Deviation: A Highly Efficient Perceptual Image Quality Index," IEEE
> Transactions on Image Processing, vol. 23, no. 2, pp. 684-695, Feb. 2014,
> doi: 10.1109/TIP.2013.2293423.

The file is included with full attribution for research use. No licence text
accompanies it, so contact the authors before redistributing it outside this
repository.

## Derived code

### `findPeaksWidthLocs`

`scripts/lib/signal/findPeaksWidthLocs.m` is a modified copy of the MathWorks
`findpeaks` function. The original notice, Copyright 2007-2023 The MathWorks,
Inc., is retained at the top of the file. Redistribution is subject to the
MathWorks licence terms for that function.

## First-party code

No licence file is included for the first-party functions in `lib/` and
`toolboxes/`. Add one before redistributing them.

## Corrections

If an attribution here is wrong or incomplete, please open an issue in this
repository.
