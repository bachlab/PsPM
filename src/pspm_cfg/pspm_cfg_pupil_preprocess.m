function [PupilPP] = pspm_cfg_pupil_preprocess(~)
% * Description
%   Matlabbatch function for pspm_pupil_pp
% * History
%   Written in 2019 by Eshref Yozdemir (University of Zurich)
%   Updated in 17-03-2024 by Teddy
% Initialise
global settings
if isempty(settings), pspm_init; end
%% Data file
DataFile          = cfg_files;
DataFile.name     = 'Data File';
DataFile.tag      = 'datafile';
DataFile.num      = [1 1];
DataFile.help     = {'Specify the PsPM datafile containing the pupil ',...
                    'recordings ', settings.datafilehelp};
%% Channel
Chan           = pspm_cfg_channel_selector('pupil');
Chan.name      = 'Primary channel to preprocess';

%% Channel to combine
ChanComb           = pspm_cfg_channel_selector('pupil_none');
ChanComb.tag       = 'chan_comb';
ChanComb.name      = 'Secondary channel to preprocess';
ChanComb.help      = {ChanComb.help{1}, ' This can be left empty.'};

% valid channel cut-off
ChanCutoff        = cfg_entry;
ChanCutoff.name   = 'Cut-off';
ChanCutoff.tag    = 'chan_valid_cutoff';
ChanCutoff.num    = [1 1];
ChanCutoff.val    = {10};
ChanCutoff.help   = {['Determine the percentage of missing values ',...
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
ChanAct           = cfg_menu;
ChanAct.name      = 'Channel action';
ChanAct.tag       = 'channel_action';
ChanAct.values    = {'add', 'replace'};
ChanAct.labels    = {'Add', 'Replace'};
ChanAct.val       = {'add'};
ChanAct.help      = {'Choose whether to add the corrected channel or ',...
                     'replace a previously corrected channel.'};
%% Parameters
% Pupil diameter minimum
PupilDiameterMin      = cfg_entry;
PupilDiameterMin.name = 'Minimum allowed pupil diameter';
PupilDiameterMin.tag  = 'PupilDiameter_Min';
PupilDiameterMin.num  = [1 1];
PupilDiameterMin.val  = {1.5};
PupilDiameterMin.help = {'Minimum allowed pupil diameter in ',...
                         'the same unit as the pupil channel.'};
% Pupil diameter maximum
PupilDiameterMax      = cfg_entry;
PupilDiameterMax.name = 'Maximum allowed pupil diameter';
PupilDiameterMax.tag  = 'PupilDiameter_Max';
PupilDiameterMax.num  = [1 1];
PupilDiameterMax.val  = {9.0};
PupilDiameterMax.help = {'Maximum allowed pupil diameter in ',...
                         'the same unit as the pupil channel.'};
% Island filter separation
IslandFiltSeparation      = cfg_entry;
IslandFiltSeparation.name = 'Island separation min distance (ms)';
IslandFiltSeparation.tag  = 'islandFilter_islandSeparation_ms';
IslandFiltSeparation.num  = [1 1];
IslandFiltSeparation.val  = {40};
IslandFiltSeparation.help = {'Minimum distance used to consider ',...
                             'samples ''separated'''};
% Minimum valid island width in millisecond
IslandFiltMinWidth        = cfg_entry;
IslandFiltMinWidth.name   = 'Min valid island width (ms)';
IslandFiltMinWidth.tag    = 'islandFilter_minIslandwidth_ms';
IslandFiltMinWidth.num    = [1 1];
IslandFiltMinWidth.val    = {50};
IslandFiltMinWidth.help   = {['Minimum temporal width required to ',...
                            'still consider a sample island ',...
                            'valid. If the temporal width of the ',...
                            'island is less than this value, all the ',...
                            'samples in the island will be marked ',...
                            'as invalid.']};
% Dilation speed filter median multiplier
DilationSpdFiltMedMp      = cfg_entry;
DilationSpdFiltMedMp.name = 'Number of medians in speed filter';
DilationSpdFiltMedMp.tag  = 'dilationSpeedFilter_MadMultiplier';
DilationSpdFiltMedMp.num  = [1 1];
DilationSpdFiltMedMp.val  = {16};
DilationSpdFiltMedMp.help = {'Number of median to use as the cutoff ',...
                            'threshold when applying the speed filter'};
% Dilation speed filter maximum gap in millisecond
DilationSpdFiltMaxGap       = cfg_entry;
DilationSpdFiltMaxGap.name  = 'Max gap to compute speed (ms)';
DilationSpdFiltMaxGap.tag   = 'dilationSpeedFilter_maxGap_ms';
DilationSpdFiltMaxGap.num   = [1 1];
DilationSpdFiltMaxGap.val   = {200};
DilationSpdFiltMaxGap.help  = {'Only calculate the speed when the gap ',...
                              'between samples is smaller than this value.'};
% Gap detect minimum width in millisecond
GapDetectMinWidth       = cfg_entry;
GapDetectMinWidth.name  = 'Min missing data width (ms)';
GapDetectMinWidth.tag   = 'gapDetect_minWidth';
GapDetectMinWidth.num   = [1 1];
GapDetectMinWidth.val   = {75};
GapDetectMinWidth.help  = {'Minimum width of a missing data section ',...
                          'that causes it to be classified as a gap.'};
% Gap detect maximum width in millisecond
GapDetectMaxWidth       = cfg_entry;
GapDetectMaxWidth.name  = 'Max missing data width (ms)';
GapDetectMaxWidth.tag   = 'gapDetect_maxWidth';
GapDetectMaxWidth.num   = [1 1];
GapDetectMaxWidth.val   = {2000};
GapDetectMaxWidth.help  = {'Maximum width of a missing data section ',...
                          'that causes it to be classified as a gap.'};
% Gap padding backword
GapPaddingBwd           = cfg_entry;
GapPaddingBwd.name      = 'Reject before missing data (ms)';
GapPaddingBwd.tag       = 'gapPadding_backward';
GapPaddingBwd.num       = [1 1];
GapPaddingBwd.val       = {50};
GapPaddingBwd.help      = {'The section right before the start of a ',...
                           'gap within which samples are to be rejected.'};
% Gap padding forward
GapPaddingFwd           = cfg_entry;
GapPaddingFwd.name      = 'Reject after missing data (ms)';
GapPaddingFwd.tag       = 'gapPadding_forward';
GapPaddingFwd.num       = [1 1];
GapPaddingFwd.val       = {50};
GapPaddingFwd.help      = {'The section right after the end of a gap ',...
                            'within which samples are to be rejected.'};
% Residual filter passes
ResdFiltPass            = cfg_entry;
ResdFiltPass.name       = 'Deviation filter passes';
ResdFiltPass.tag        = 'residualsFilter_passes';
ResdFiltPass.num        = [1 1];
ResdFiltPass.val        = {4};
ResdFiltPass.help       = {'Number of passes deviation filter makes'};
% Residual filter median multiplier
ResdFiltMedMp           = cfg_entry;
ResdFiltMedMp.name      = 'Number of medians in deviation filter';
ResdFiltMedMp.tag       = 'residualsFilter_MadMultiplier';
ResdFiltMedMp.num       = [1 1];
ResdFiltMedMp.val       = {16};
ResdFiltMedMp.help      = {['The multiplier used when defining the ',...
                            'threshold. Threshold equals this ',...
                            'multiplier times the median. After ',...
                            'each pass, all the input samples that ',...
                            'are outside the threshold are removed. ',...
                            'Please note that all samples (even the ',...
                            'ones which may have been rejected by ',...
                            'the previous devation filter pass) are ',...
                            'considered.']};
% Residual filter interpolation sampling frequency
ResdFiltInterpFs        = cfg_entry;
ResdFiltInterpFs.name   = 'Butterworth sampling frequency (Hz)';
ResdFiltInterpFs.tag    = 'residualsFilter_interpFs';
ResdFiltInterpFs.num    = [1 1];
ResdFiltInterpFs.val    = {100};
ResdFiltInterpFs.help   = {'Sampling frequency for first order ',...
                           'Butterworth filter.'};
% Residual filter for lowpass cut-off
ResdFiltLPCF            = cfg_entry;
ResdFiltLPCF.name       = 'Butterworth cutoff frequency (Hz)';
ResdFiltLPCF.tag        = 'residualsFilter_interpFs';
ResdFiltLPCF.num        = [1 1];
ResdFiltLPCF.val        = {100};
ResdFiltLPCF.help       = {'Cutoff frequency for first order ',...
                            'Butterworth filter.'};
% Keep filter data
KeepFiltData            = cfg_menu;
KeepFiltData.name       = 'Store intermediate steps';
KeepFiltData.tag        = 'keepFilterData';
KeepFiltData.values     = {true, false};
KeepFiltData.labels     = {'True', 'False'};
KeepFiltData.val        = {false};
KeepFiltData.help       = {['If true, intermediate filter data will ',...
                            'be stored for plotting. ',...
                            'Set to false to save memory and improve ',...
                            'plotting performance.']};
% Raw custom setting
RawCustomSet            = cfg_branch;
RawCustomSet.name       = 'Settings for raw data preprocessing';
RawCustomSet.tag        = 'raw';
RawCustomSet.val        = {PupilDiameterMin,...
                           PupilDiameterMax,...
                           IslandFiltSeparation,...
                           IslandFiltMinWidth,...
                           DilationSpdFiltMedMp,...
                           DilationSpdFiltMaxGap,...
                           GapDetectMinWidth,...
                           GapDetectMaxWidth,...
                           GapPaddingBwd,...
                           GapPaddingFwd,...
                           ResdFiltPass,...
                           ResdFiltMedMp,...
                           ResdFiltInterpFs,...
                           ResdFiltLPCF,...
                           KeepFiltData...
                          };
% Interpolation upsampling frequency
InterpUpSampFreq        = cfg_entry;
InterpUpSampFreq.name   = 'Interpolation upsampling frequency (Hz)';
InterpUpSampFreq.tag    = 'interp_upsamplingFreq';
InterpUpSampFreq.num    = [1 1];
InterpUpSampFreq.val    = {1000};
InterpUpSampFreq.help   = {'The upsampling frequency used to generate ',...
                           'the smooth signal. (Hz)'};
% Low pass filter cutoff frequency in Hz
LPFiltCutoffFreq        = cfg_entry;
LPFiltCutoffFreq.name   = 'Lowpass filter cutoff frequency (Hz)';
LPFiltCutoffFreq.tag    = 'LpFilt_cutoffFreq';
LPFiltCutoffFreq.num    = [1 1];
LPFiltCutoffFreq.val    = {4};
LPFiltCutoffFreq.help   = {'Cutoff frequency of the lowpass filter ',...
                           'used during final smoothing. (Hz)'};
% Low pass filter order
LPFiltOrder             = cfg_entry;
LPFiltOrder.name        = 'Lowpass filter order';
LPFiltOrder.tag         = 'LpFilt_order';
LPFiltOrder.num         = [1 1];
LPFiltOrder.val         = {4};
LPFiltOrder.help        = {'Filter order of the lowpass filter used ',...
                           'during final smoothing.'};
% Interpolation maximum gap in millisecond
InterpMaxGap            = cfg_entry;
InterpMaxGap.name       = 'Interpolation max gap (ms)';
InterpMaxGap.tag        = 'interp_maxGap';
InterpMaxGap.num        = [1 1];
InterpMaxGap.val        = {250};
InterpMaxGap.help       = {['Maximum gap in the used (valid) raw ',...
                            'samples to interpolate over. ',...
                            'Sections that were interpolated over ',...
                            'distances larger than this value will ',...
                            'be set to NaN. (ms)']};
%% Settings
% Settings for valid data preprocessing
ValidCustomSet          = cfg_branch;
ValidCustomSet.name     = 'Settings for valid data preprocessing';
ValidCustomSet.tag      = 'valid';
ValidCustomSet.val      = {InterpUpSampFreq, ...
                           LPFiltCutoffFreq, ...
                           LPFiltOrder, ...
                           InterpMaxGap...
                          };
% Custom settings
CustomSet               = cfg_branch;
CustomSet.name          = 'Custom settings';
CustomSet.tag           = 'custom_settings';
CustomSet.val           = {RawCustomSet, ValidCustomSet};
% Default settings
DefaultSet              = cfg_const;
DefaultSet.name         = 'Default settings';
DefaultSet.tag          = 'default_settings';
DefaultSet.val          = {'Default settings'};
% Settings
Set                     = cfg_choice;
Set.name                = 'Settings';
Set.tag                 = 'settings';
Set.values              = {DefaultSet, CustomSet};
Set.val                 = {DefaultSet};
Set.help                = {'Define settings to modify preprocessing'};
%% Segments
% Segement start in second
SegStart                = cfg_entry;
SegStart.name           = 'Segment start (seconds)';
SegStart.tag            = 'start';
SegStart.num            = [1 1];
SegStart.help           = {'Segment start, in seconds.'};
% Segment end in second
SegEnd                  = cfg_entry;
SegEnd.name             = 'Segment end (seconds)';
SegEnd.tag              = 'end';
SegEnd.num              = [1 1];
SegEnd.help             = {'Segment end, in seconds.'};
% Segment name
SegName                 = cfg_entry;
SegName.name            = 'Segment name';
SegName.strtype         = 's';
SegName.tag             = 'name';
SegName.help            = {'Segment name'};
% Segment
Seg                     = cfg_branch;
Seg.name                = 'Segment';
Seg.tag                 = 'segments';
Seg.val                 = {SegStart, SegEnd, SegName};
% Segment repeat
SegRep                  = cfg_repeat;
SegRep.name             = 'Segments';
SegRep.tag              = 'segments_rep';
SegRep.values           = {Seg};
SegRep.num              = [0 Inf];
SegRep.help             = {['Define segments to calculate statistics ',...
                            'on. These segments will be stored in ',...
                            'the output channel and also will be ',...
                            'show if plotting is enabled']...
                           };
%% Plot data
PlotData                = cfg_menu;
PlotData.name           = 'Plot data';
PlotData.tag            = 'plot_data';
PlotData.values         = {true, false};
PlotData.labels         = {'True', 'False'};
PlotData.val            = {false};
PlotData.help           = {'Please choose whether to plot the data.'};
%% Executable branch
PupilPP                 = cfg_exbranch;
PupilPP.name            = 'Pupil preprocessing';
PupilPP.tag             = 'pupil_preprocess';
PupilPP.val             = {DataFile, ...
                           Chan, ...
                           ChanComb, ...
                           ChanCutoff, ...
                           ChanAct, ...
                           Set, ...
                           SegRep, ...
                           PlotData ...
                          };
PupilPP.prog            = @pspm_cfg_run_pupil_preprocess;
PupilPP.vout            = @pspm_cfg_vout_pupil_preprocess;
PupilPP.help            = {['Pupil size preprocessing using the ',...
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
