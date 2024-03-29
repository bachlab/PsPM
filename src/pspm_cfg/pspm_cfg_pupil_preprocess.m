function [pupil_pp] = pspm_cfg_pupil_preprocess(~)
% * Description
%   Matlabbatch function for pspm_pupil_pp
% * History
%   Written in 2019 by Eshref Yozdemir (University of Zurich)
%   Updated in 17-03-2024 by Teddy
% Initialise
global settings
if isempty(settings), pspm_init; end
%% Data file
datafile                = cfg_files;
datafile.name           = 'Data File';
datafile.tag            = 'datafile';
datafile.num            = [1 1];
datafile.help           = {'Specify the PsPM datafile containing the ',...
                           'pupil recordings ', settings.datafilehelp};
%% Channel
chan                    = pspm_cfg_channel_selector('pupil');
chan.name               = 'Primary channel to preprocess';
%% Channel to combine
chan_comb               = pspm_cfg_channel_selector('pupil_none');
chan_comb.tag           = 'chan_comb';
chan_comb.name          = 'Secondary channel to preprocess';
chan_comb.help          = {chan_comb.help{1}, ' This can be left empty.'};

% valid channel cut-off
chan_cutoff             = cfg_entry;
chan_cutoff.name        = 'Cut-off';
chan_cutoff.tag         = 'chan_valid_cutoff';
chan_cutoff.num         = [1 1];
chan_cutoff.val         = {10};
chan_cutoff.help        = {['Determine the percentage of missing values ',...
                           '(NaNs) in the dataset. The default value is ',...
                           '10%. Any value from 0-100 can be entereed. ',...
                           'A warning will be thrown if any data channel contains ',...
                           'more missing values than this cutoff. ',...
                           'If channel combination is requested and only one ',...
                           'channel has fewer missing values than the cutoff, ',...
                           'then the better channel will be used ',...
                           'and no combination will be performed. ',...
                           'Otherwise, the channels will be combined, ',...
                           'even if both have more missing values.']};
% define channel_action
chan_act                = cfg_menu;
chan_act.name           = 'Channel action';
chan_act.tag            = 'channel_action';
chan_act.values         = {'add', 'replace'};
chan_act.labels         = {'Add', 'Replace'};
chan_act.val            = {'add'};
chan_act.help           = {'Choose whether to add the corrected channel ',...
                          'or replace a previously corrected channel.'};
%% Parameters
% Pupil diameter minimum
pupil_diameter_min      = cfg_entry;
pupil_diameter_min.name = 'Minimum allowed pupil diameter';
pupil_diameter_min.tag  = 'PupilDiameter_Min';
pupil_diameter_min.num  = [1 1];
pupil_diameter_min.val  = {1.5};
pupil_diameter_min.help = {'Minimum allowed pupil diameter in ',...
                           'the same unit as the pupil channel.'};
% Pupil diameter maximum
pupil_diameter_max      = cfg_entry;
pupil_diameter_max.name = 'Maximum allowed pupil diameter';
pupil_diameter_max.tag  = 'PupilDiameter_Max';
pupil_diameter_max.num  = [1 1];
pupil_diameter_max.val  = {9.0};
pupil_diameter_max.help = {'Maximum allowed pupil diameter in ',...
                           'the same unit as the pupil channel.'};
% Island filter separation
island_filt_sep         = cfg_entry;
island_filt_sep.name    = 'Island separation min distance (ms)';
island_filt_sep.tag     = 'islandFilter_islandSeparation_ms';
island_filt_sep.num     = [1 1];
island_filt_sep.val     = {40};
island_filt_sep.help    = {'Minimum distance used to consider ',...
                           'samples ''separated'''};
% Minimum valid island width in millisecond
isld_filt_min_w         = cfg_entry;
isld_filt_min_w.name    = 'Min valid island width (ms)';
isld_filt_min_w.tag     = 'islandFilter_minIslandwidth_ms';
isld_filt_min_w.num     = [1 1];
isld_filt_min_w.val     = {50};
isld_filt_min_w.help    = {['Minimum temporal width required to ',...
                            'still consider a sample island ',...
                            'valid. If the temporal width of the ',...
                            'island is less than this value, all the ',...
                            'samples in the island will be marked ',...
                            'as invalid.']};
% Dilation speed filter median multiplier
dila_spd_filt_med_mp    = cfg_entry;
dila_spd_filt_med_mp.name = 'Number of medians in speed filter';
dila_spd_filt_med_mp.tag  = 'dilationSpeedFilter_MadMultiplier';
dila_spd_filt_med_mp.num  = [1 1];
dila_spd_filt_med_mp.val  = {16};
dila_spd_filt_med_mp.help = {'Number of median to use as the cutoff ',...
                            'threshold when applying the speed filter'};
% Dilation speed filter maximum gap in millisecond
dila_spd_filt_max_gap   = cfg_entry;
dila_spd_filt_max_gap.name  = 'Max gap to compute speed (ms)';
dila_spd_filt_max_gap.tag   = 'dilationSpeedFilter_maxGap_ms';
dila_spd_filt_max_gap.num   = [1 1];
dila_spd_filt_max_gap.val   = {200};
dila_spd_filt_max_gap.help  = {'Only calculate the speed when the gap ',...
                              'between samples is smaller than this value.'};
% Gap detect minimum width in millisecond
gap_det_min_w           = cfg_entry;
gap_det_min_w.name      = 'Min missing data width (ms)';
gap_det_min_w.tag       = 'gapDetect_minWidth';
gap_det_min_w.num       = [1 1];
gap_det_min_w.val       = {75};
gap_det_min_w.help      = {'Minimum width of a missing data section ',...
                          'that causes it to be classified as a gap.'};
% Gap detect maximum width in millisecond
gap_det_max_w           = cfg_entry;
gap_det_max_w.name      = 'Max missing data width (ms)';
gap_det_max_w.tag       = 'gapDetect_maxWidth';
gap_det_max_w.num       = [1 1];
gap_det_max_w.val       = {2000};
gap_det_max_w.help      = {'Maximum width of a missing data section ',...
                          'that causes it to be classified as a gap.'};
% Gap padding backword
gap_pad_bkwd            = cfg_entry;
gap_pad_bkwd.name       = 'Reject before missing data (ms)';
gap_pad_bkwd.tag        = 'gapPadding_backward';
gap_pad_bkwd.num        = [1 1];
gap_pad_bkwd.val        = {50};
gap_pad_bkwd.help       = {'The section right before the start of a ',...
                           'gap within which samples are to be rejected.'};
% Gap padding forward
gap_pad_fwd             = cfg_entry;
gap_pad_fwd.name        = 'Reject after missing data (ms)';
gap_pad_fwd.tag         = 'gapPadding_forward';
gap_pad_fwd.num         = [1 1];
gap_pad_fwd.val         = {50};
gap_pad_fwd.help        = {'The section right after the end of a gap ',...
                            'within which samples are to be rejected.'};
% Residual filter passes
resd_filt_pass          = cfg_entry;
resd_filt_pass.name     = 'Deviation filter passes';
resd_filt_pass.tag      = 'residualsFilter_passes';
resd_filt_pass.num      = [1 1];
resd_filt_pass.val      = {4};
resd_filt_pass.help     = {'Number of passes deviation filter makes'};
% Residual filter median multiplier
resd_filt_med_mp        = cfg_entry;
resd_filt_med_mp.name   = 'Number of medians in deviation filter';
resd_filt_med_mp.tag    = 'residualsFilter_MadMultiplier';
resd_filt_med_mp.num    = [1 1];
resd_filt_med_mp.val    = {16};
resd_filt_med_mp.help   = {['The multiplier used when defining the ',...
                            'threshold. Threshold equals this ',...
                            'multiplier times the median. After ',...
                            'each pass, all the input samples that ',...
                            'are outside the threshold are removed. ',...
                            'Please note that all samples (even the ',...
                            'ones which may have been rejected by ',...
                            'the previous devation filter pass) are ',...
                            'considered.']};
% Residual filter interpolation sampling frequency
resd_filt_int_fs        = cfg_entry;
resd_filt_int_fs.name   = 'Butterworth sampling frequency (Hz)';
resd_filt_int_fs.tag    = 'residualsFilter_interpFs';
resd_filt_int_fs.num    = [1 1];
resd_filt_int_fs.val    = {100};
resd_filt_int_fs.help   = {'Sampling frequency for first order ',...
                           'Butterworth filter.'};
% Residual filter for lowpass cut-off
resd_filt_lp_cf         = cfg_entry;
resd_filt_lp_cf.name    = 'Butterworth cutoff frequency (Hz)';
resd_filt_lp_cf.tag     = 'residualsFilter_interpFs';
resd_filt_lp_cf.num     = [1 1];
resd_filt_lp_cf.val     = {100};
resd_filt_lp_cf.help    = {'Cutoff frequency for first order ',...
                           'Butterworth filter.'};
% Keep filter data
keep_filt_data          = cfg_menu;
keep_filt_data.name     = 'Store intermediate steps';
keep_filt_data.tag      = 'keepFilterData';
keep_filt_data.values   = {true, false};
keep_filt_data.labels   = {'True', 'False'};
keep_filt_data.val      = {false};
keep_filt_data.help     = {['If true, intermediate filter data will ',...
                            'be stored for plotting. ',...
                            'Set to false to save memory and improve ',...
                            'plotting performance.']};
% Raw custom setting
set_raw_custom          = cfg_branch;
set_raw_custom.name     = 'Settings for raw data preprocessing';
set_raw_custom.tag      = 'raw';
set_raw_custom.val      = {pupil_diameter_min,...
                           pupil_diameter_max,...
                           island_filt_sep,...
                           isld_filt_min_w,...
                           dila_spd_filt_med_mp,...
                           dila_spd_filt_max_gap,...
                           gap_det_min_w,...
                           gap_det_max_w,...
                           gap_pad_bkwd,...
                           gap_pad_fwd,...
                           resd_filt_pass,...
                           resd_filt_med_mp,...
                           resd_filt_int_fs,...
                           resd_filt_lp_cf,...
                           keep_filt_data...
                          };
% Interpolation upsampling frequency
interp_upsamp_freq      = cfg_entry;
interp_upsamp_freq.name = 'Interpolation upsampling frequency (Hz)';
interp_upsamp_freq.tag  = 'interp_upsamplingFreq';
interp_upsamp_freq.num  = [1 1];
interp_upsamp_freq.val  = {1000};
interp_upsamp_freq.help = {'The upsampling frequency used to generate ',...
                           'the smooth signal. (Hz)'};
% Low pass filter cutoff frequency in Hz
lp_filt_cf_freq         = cfg_entry;
lp_filt_cf_freq.name    = 'Lowpass filter cutoff frequency (Hz)';
lp_filt_cf_freq.tag     = 'LpFilt_cutoffFreq';
lp_filt_cf_freq.num     = [1 1];
lp_filt_cf_freq.val     = {4};
lp_filt_cf_freq.help    = {'Cutoff frequency of the lowpass filter ',...
                           'used during final smoothing. (Hz)'};
% Low pass filter order
lowpass_filt_order      = cfg_entry;
lowpass_filt_order.name = 'Lowpass filter order';
lowpass_filt_order.tag  = 'LpFilt_order';
lowpass_filt_order.num  = [1 1];
lowpass_filt_order.val  = {4};
lowpass_filt_order.help = {'Filter order of the lowpass filter used ',...
                           'during final smoothing.'};
% Interpolation maximum gap in millisecond
interp_max_gap          = cfg_entry;
interp_max_gap.name     = 'Interpolation max gap (ms)';
interp_max_gap.tag      = 'interp_maxGap';
interp_max_gap.num      = [1 1];
interp_max_gap.val      = {250};
interp_max_gap.help     = {['Maximum gap in the used (valid) raw ',...
                            'samples to interpolate over. ',...
                            'Sections that were interpolated over ',...
                            'distances larger than this value will ',...
                            'be set to NaN. (ms)']};
%% Settings
% Settings for valid data preprocessing
valid_custom_set        = cfg_branch;
valid_custom_set.name   = 'Settings for valid data preprocessing';
valid_custom_set.tag    = 'valid';
valid_custom_set.val    = {interp_upsamp_freq, ...
                           lp_filt_cf_freq, ...
                           lowpass_filt_order, ...
                           interp_max_gap...
                          };
% Custom settings
set_custom              = cfg_branch;
set_custom.name         = 'Custom settings';
set_custom.tag          = 'custom_settings';
set_custom.val          = {set_raw_custom, valid_custom_set};
% Default settings
set_default             = cfg_const;
set_default.name        = 'Default settings';
set_default.tag         = 'default_settings';
set_default.val         = {'Default settings'};
% Settings
set                     = cfg_choice;
set.name                = 'Settings';
set.tag                 = 'settings';
set.values              = {set_default, set_custom};
set.val                 = {set_default};
set.help                = {'Define settings to modify preprocessing'};
%% Segments
% Segement start in second
seg_start               = cfg_entry;
seg_start.name          = 'Segment start (seconds)';
seg_start.tag           = 'start';
seg_start.num           = [1 1];
seg_start.help          = {'Segment start, in seconds.'};
% Segment end in second
seg_end                 = cfg_entry;
seg_end.name            = 'Segment end (seconds)';
seg_end.tag             = 'end';
seg_end.num             = [1 1];
seg_end.help            = {'Segment end, in seconds.'};
% Segment name
seg_name                = cfg_entry;
seg_name.name           = 'Segment name';
seg_name.strtype        = 's';
seg_name.tag            = 'name';
seg_name.help           = {'Segment name'};
% Segment
seg                     = cfg_branch;
seg.name                = 'Segment';
seg.tag                 = 'segments';
seg.val                 = {seg_start, seg_end, seg_name};
% Segment repeat
seg_rep                 = cfg_repeat;
seg_rep.name            = 'Segments';
seg_rep.tag             = 'segments_rep';
seg_rep.values          = {seg};
seg_rep.num             = [0 Inf];
seg_rep.help            = {['Define segments to calculate statistics ',...
                            'on. These segments will be stored in ',...
                            'the output channel and also will be ',...
                            'show if plotting is enabled']...
                           };
%% Plot data
plotdata                = cfg_menu;
plotdata.name           = 'Plot data';
plotdata.tag            = 'plot_data';
plotdata.values         = {true, false};
plotdata.labels         = {'True', 'False'};
plotdata.val            = {false};
plotdata.help           = {'Please choose whether to plot the data.'};
%% Executable branch
pupil_pp                = cfg_exbranch;
pupil_pp.name           = 'Pupil preprocessing';
pupil_pp.tag            = 'pupil_preprocess';
pupil_pp.val            = {datafile, ...
                           chan, ...
                           chan_comb, ...
                           chan_cutoff, ...
                           chan_act, ...
                           set, ...
                           seg_rep, ...
                           plotdata ...
                          };
pupil_pp.prog           = @pspm_cfg_run_pupil_preprocess;
pupil_pp.vout           = @pspm_cfg_vout_pupil_preprocess;
pupil_pp.help           = {['Pupil size preprocessing using the ',...
                            'steps described in the reference article. ',...
                            'The function allows users to preprocess ',...
                            'two eyes simultaneously and average  ',...
                            'them in addition to offering single  ',...
                            'eye preprocessing. ',...
                            'Further, users can define segments on ',...
                            'which statistics such as min, max, mean, ',...
                            'etc. will be computed. In order to get ',...
                            'information about the preprocessing ',...
                            'steps, please refer to pupil ',...
                            'preprocessing user guide section in PsPM ',...
                            ' manual for an explanation.'],...
                           ['Reference: Kret, Mariska E., and Elio E. ',...
                            'Sjak-Shie. "Preprocessing pupil size data: ',...
                            'Guidelines and code." Behavior research ',...
                            'methods (2018): 1-7.']...
                           };
%% Running function
function vout = pspm_cfg_vout_pupil_preprocess(~)
vout = cfg_dep;
vout.sname      = 'Output File';
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}}); % only cfg_files
vout.src_output = substruct('()',{':'});