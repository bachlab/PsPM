function [sts, default_settings] = pspm_pupil_pp_options()
% ● Description
%   pspm_pupil_pp_options is a helper function that can be used to modify the
%   behaviour of pspm_pupil_pp function. This function returns the settings
%   structure used by pspm_pupil_pp for pupil preprocessing. You can modify the
%   returned structure and then pass it to pspm_pupil_pp. See below for
%   explanation of the parameters. Adapted from:
%   - pspm/pupil-size/code/helperFunctions/rawDataFilter.m lines 63 to 149,
%   - pspm/pupil-size/code/dataModels/ValidSamplesModel.m lines 357 to 373.
% ● Format
%   [sts, default_settings] = pspm_pupil_pp_options()
% ● Outputs
%     default_settings: Structure with the fields below.
%   ▶︎ Allowable values criteria
%     raw.PupilDiameter_Min:  Minimum allowable pupil size. Pupil values less 
%                             than this value will be marked as invalid.
%                             (Default: 1.5)
%     raw.PupilDiameter_Max:  Maximum allowable pupil size. Pupil values  
%                             greater than thin value will be markes as invalid.
%                             (Default: 9.0)
%   ▶︎ Isolated sample filter criteria
%       // 'Sample-islands' are clusters of samples that are temporally 
%       // seperated from other samples.
%     raw.islandFilter_islandSeperation_ms:
%                             Minimum distance used to consider samples
%                             'separated'. (Default: 40 ms)
%     raw.islandFilter_minIslandWidth_ms:
%                             Minimum temporal width required to still consider
%                             a sample island valid. If the temporal width of
%                             the island is less than this value, all the
%                             samples in the island will be marked as invalid.
%                             (Default: 50 ms)
%   ▶︎ Dilation speed filter criteria
%     raw.dilationSpeedFilter_MadMultiplier:
%                             Number of medians to use as the cutoff threshold 
%                             when applying the speed filter. (Default: 16)
%     raw.dilationSpeedFilter_maxGap_ms:
%                             Only calculate the speed when the gap between
%                             samples is smaller than this value.
%                             (Default: 200 ms)
%   ▶︎ Edge removal filter criteria
%       // Sometimes gaps in the data after the dilation speed filter feature
%       // artifacts at their edges. These artifacts are not always removed by
%       // the dilation speed filter; as such, samples arounds these gaps may
%       // also need to be marked as invalid. The settings below indicate when a
%       // section of missing data is classified as a gap (samples around these
%       // gaps are in turn rejected).
%     raw.gapDetect_minWidth: Minimum width of a missing data section that
%                             causes it to be classified as a gap.
%                             (Default: 75 ms)
%     raw.gapDetect_maxWidth: Maximum width of a missing data section that
%                             causes it to be classified as a gap.
%                             (Default: 2000 ms)
%     raw.gapPadding_backward:The section right before the start of a gap
%                             within which samples are to be rejected.
%                             (Default: 50 ms)
%     raw.gapPadding_forward: The section right after the end of a gap within
%                             which samples are to be rejected. (Default: 50 ms)
%   ▶︎ Deviation filter criteria
%       // At this point a subset of the original samples are marked as valid.
%       // These samples are the input for this filter. The dilation speed 
%       // filter will not reject samples that do not feature outlying speeds, 
%       // such as is the case when these samples are clustered together. As 
%       // such, a deviation from a smooth trendline filter is warranted.
%     raw.residualsFilter_passes:
%                             Number of passes the deviation filter makes.
%                             (Default: 4)
%     raw.residualsFilter_MadMultiplier:
%                             The multiplier used when defining the threshold.
%                             Threshold equals this multiplier times the median.
%                             After each pass, all the input samples that are
%                             outside the threshold are removed. Note that all
%                             samples (even the ones which may have been
%                             rejected by the previous devation filter pass)
%                             are considered. (Default: 16)
%   ▶︎ 
%       // At each pass, a smooth continuous trendline is generated using the
%       // data below, from which the deviation is than calculated and used as
%       // the filter criteria. The below computation is performed:
%       // [lowpassB, lowpassA] = butter(1, lowpassCF/(interpFs/2));
%     raw.residualsFilter_interpFs:
%                             Fs for first order Butterworth filter.
%                             (Default: 100 Hz)
%     raw.residualsFilter_lowpassCF:
%                             Cutoff frequency for first order Butterworth
%                             filter. (Default: 16 Hz)
%   ▶︎ Keep filter data
%     raw.keepFilterData:     If true, intermediate filter data will be stored.
%                             Set to false to save memory and improve plotting
%                             performance. (Default: true)
%   ▶︎ Final data smoothing
%     valid.interp_upsamplingFreq:
%                             The upsampling frequency used to generate the
%                             smooth signal. (Default: 1000 Hz)
%     valid.LpFilt_cutoffFreq:Cutoff frequency of the lowpass filter used
%                             during final smoothing. (Default: 4 Hz)
%     valid.LpFilt_order:     Filter order of the lowpass filter used during
%                             final smoothing. (Default: 4)
%     valid.interp_maxGap:    Maximum gap in the used (valid) raw samples to
%                             interpolate over. Sections that were interpolated
%                             over distances larger than this value will be
%                             set to NaN. (Default: 250 ms)
% ● Copyright
%   Introduced In TBA.
% ● Written By
%   (C) 2019 Eshref Yozdemir (University of Zurich)
% ● Maintained By
%   2022 Teddy Chao (UCL)

global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
libbase_path = pspm_path('ext','pupil-size', 'code');
libpath = {fullfile(libbase_path, 'dataModels'), fullfile(libbase_path, 'helperFunctions')};
addpath(libpath{:});
default_settings = PupilDataModel.getDefaultSettings();
rmpath(libpath{:});
sts = 1;
end