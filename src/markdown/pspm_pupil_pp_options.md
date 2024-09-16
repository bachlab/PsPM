# pspm_pupil_pp_options
## Description
pspm_pupil_pp_options is a helper function that can be used to modify the behaviour of pspm_pupil_pp function. This function returns the settings structure used by pspm_pupil_pp for pupil preprocessing. You can modify the returned structure and then pass it to pspm_pupil_pp. See below for explanation of the parameters. Adapted from: - pspm/pupil-size/code/helperFunctions/rawDataFilter.m lines 63 to 149, - pspm/pupil-size/code/dataModels/ValidSamplesModel.m lines 357 to 373.

## Format
`[sts, default_settings] = pspm_pupil_pp_options()`

## Outputs
| Variable | Definition |
|:--|:--|
| default_settings | Structure with the fields below. |
| raw | See following fields. |
| raw.PupilDiameter_Min | Minimum allowable pupil size. Pupil values less than this value will be marked as invalid. (Default: 1.5). |
| raw.PupilDiameter_Max | Maximum allowable pupil size. Pupil values greater than thin value will be marked as invalid. (Default: 9.0). |
| raw.islandFilter_islandSeperation_ms | Minimum distance used to consider samples 'separated'. (Default: 40 ms). |
| raw.islandFilter_minIslandWidth_ms | Minimum temporal width required to still consider a sample island valid. If the temporal width of the island is less than this value, all the samples in the island will be marked as invalid. (Default: 50 ms). |
| raw.dilationSpeedFilter_MadMultiplier | Number of medians to use as the cutoff threshold when applying the speed filter. (Default: 16). |
| raw.dilationSpeedFilter_maxGap_ms | Only calculate the speed when the gap between samples is smaller than this value. (Default: 200 ms). |
| raw.gapDetect_minWidth | Minimum width of a missing data section that causes it to be classified as a gap. (Default: 75 ms). |
| raw.gapDetect_maxWidth | Maximum width of a missing data section that causes it to be classified as a gap. (Default: 2000 ms). |
| raw.gapPadding_backward | The section right before the start of a gap within which samples are to be rejected. (Default: 50 ms). |
| raw.gapPadding_forward | The section right after the end of a gap within which samples are to be rejected. (Default: 50 ms). |
| raw.residualsFilter_passes | Number of passes the deviation filter makes. (Default: 4). |
| raw.residualsFilter_MadMultiplier | The multiplier used when defining the threshold. Threshold equals this multiplier times the median. After each pass, all the input samples that are outside the threshold are removed. Note that all samples (even the ones which may have been rejected by the previous deviation filter pass) are considered. (Default: 16). |
| raw.residualsFilter_interpFs | Fs for first order Butterworth filter. (Default: 100 Hz). |
| raw.residualsFilter_lowpassCF | Cutoff frequency for first order Butterworth filter. (Default: 16 Hz). |
| raw.keepFilterData | If true, intermediate filter data will be stored. Set to false to save memory and improve plotting performance. (Default: true). || valid | See following fields. |
| valid.interp_upsamplingFreq | The upsampling frequency used to generate the smooth signal. (Default: 1000 Hz). |
| valid.LpFilt_cutoffFreq | Cutoff frequency of the lowpass filter used during final smoothing. (Default: 4 Hz). |
| valid.LpFilt_order | Filter order of the lowpass filter used during final smoothing. (Default: 4). |
| valid.interp_maxGap | Maximum gap in the used (valid) raw samples to interpolate over. Sections that were interpolated over distances larger than this value will be set to NaN. (Default: 250 ms). |
