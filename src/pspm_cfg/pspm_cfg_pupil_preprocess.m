function [PupilPP] = pspm_cfg_pupil_preprocess(~)
% * Description
%   Matlabbatch function for pspm_pupil_pp
% * History
%   Written in 2019 by Eshref Yozdemir (University of Zurich)
%   Updated in 2024 by Teddy
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
% channel number
ChanNum           = cfg_entry;
ChanNum.name      = 'Channel number';
ChanNum.tag       = 'chan_nr';
ChanNum.num       = [1 1];
ChanNum.help      = {'Enter a channel number'};
% channel definition
ChanDef           = cfg_menu;
ChanDef.name      = 'Channel definition';
ChanDef.tag       = 'chan_def';
ChanDef.values    = {'pupil'    , ...
                    'pupil_l'   , ...
                    'pupil_r'   , ...
                    'pupil_c'   , ...
                    'pupil_pp_l', ...
                    'pupil_pp_r', ...
                    'pupil_pp_c'};
ChanDef.labels    = {'Pupil best'               , ...
                    'Pupil left'                , ...
                    'Pupil right'               , ...
                    'Pupil combined'            , ...
                    'Pupil preprocessed left'   , ...
                    'Pupil preprocessed right'  , ...
                    'Pupil preprocessed combined'};
ChanDef.val       = {'pupil'};
ChanDef.help      = {['Choose the channel definition. ',...
                    'Only the last channel in the file corresponding ',....
                    'to the selection will be corrected.']};
% primary channel
Chan              = cfg_choice;
Chan.name         = 'Primary channel to preprocess';
Chan.tag          = 'channel';
Chan.values       = {ChanDef, ChanNum};
Chan.val          = {ChanDef};
Chan.help         = {'Choose the primary channel to preprocess.'};
%% Channel to combine (ChanCombDef)
ChanCombDef       = cfg_menu;
ChanCombDef.name  = 'Channel definition';
ChanCombDef.tag   = 'chan_def';
ChanCombDef.values  = {'none'       , ...
                      'pupil_l'     , ...
                      'pupil_r'     , ...
                      'pupil_pp_l'  , ...
                      'pupil_pp_r'};
ChanCombDef.labels  = {'No combining',...
                      'Pupil left',...
                      'Pupil right',...
                      'Pupil preprocessed left',...
                      'Pupil preprocessed right'};
ChanCombDef.val   = {'none'};
ChanCombDef.help  = {['Choose the channel definition. ',...
                    'Only the last channel in the file ',...
                    'corresponding to the selection ',...
                    'will be used.']};
% channel to combine
ChanComb          = cfg_choice;
ChanComb.name     = 'Secondary channel to preprocess and combine';
ChanComb.tag      = 'channel_combine';
ChanComb.values   = {ChanCombDef, ChanNum};
ChanComb.val      = {ChanCombDef};
ChanComb.help     = {['Choose the secondary channel to preprocess using ',...
                    'the exact same steps. Afterwards this channel ', ...
                    'will be combined with primary channel in order ',...
                    'to create a preprocessed mean channel. Note that ',...
                    'the recorded eye in secondary channel must be ',...
                    'different than the recorded eye in primary channel']};
% valid channel cut-off
ChanValidCutoff       = cfg_entry;
ChanValidCutoff.name  = 'Cut-off';
ChanValidCutoff.tag   = 'chan_valid_cutoff';
ChanValidCutoff.num   = [1 1];
ChanValidCutoff.val   = {10};
ChanValidCutoff.help  = {''};
% define channel_action
ChanAct           = cfg_menu;
ChanAct.name      = 'Channel action';
ChanAct.tag       = 'channel_action';
ChanAct.values    = {'add', 'replace'};
ChanAct.labels    = {'Add', 'Replace'};
ChanAct.val       = {'add'};
ChanAct.help      = {'Choose whether to add the corrected channel or ',...
                     'replace a previously corrected channel.'};
%% Settings
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

GapPaddingBwd           = cfg_entry;
GapPaddingBwd.name      = 'Reject before missing data (ms)';
GapPaddingBwd.tag       = 'gapPadding_backward';
GapPaddingBwd.num       = [1 1];
GapPaddingBwd.val       = {50};
GapPaddingBwd.help      = {'The section right before the start of a ',...
                            'gap within which samples are to be rejected.'};

GapPaddingFwd           = cfg_entry;
GapPaddingFwd.name      = 'Reject after missing data (ms)';
GapPaddingFwd.tag       = 'gapPadding_forward';
GapPaddingFwd.num       = [1 1];
GapPaddingFwd.val       = {50};
GapPaddingFwd.help      = {'The section right after the end of a gap ',...
                            'within which samples are to be rejected.'};

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
ResdFiltInterpFs = cfg_entry;
ResdFiltInterpFs.name = 'Butterworth sampling frequency (Hz)';
ResdFiltInterpFs.tag = 'residualsFilter_interpFs';
ResdFiltInterpFs.num = [1 1];
ResdFiltInterpFs.val = {100};
ResdFiltInterpFs.help = {'Fs for first order Butterworth filter.'};

ResdFiltLPCF = cfg_entry;
ResdFiltLPCF.name = 'Butterworth cutoff frequency (Hz)';
ResdFiltLPCF.tag = 'residualsFilter_interpFs';
ResdFiltLPCF.num = [1 1];
ResdFiltLPCF.val = {100};
ResdFiltLPCF.help = {'Cutoff frequency for first order Butterworth filter.'};

KeepFiltData = cfg_menu;
KeepFiltData.name = 'Store intermediate steps';
KeepFiltData.tag = 'keepFilterData';
KeepFiltData.values = {true, false};
KeepFiltData.labels = {'True', 'False'};
KeepFiltData.val = {false};
KeepFiltData.help = {['If true, intermediate filter data will be stored for plotting. ',...
  'Set to false to save memory and improve plotting performance.']};

RawCustomSet = cfg_branch;
RawCustomSet.name = 'Settings for raw preprocessing';
RawCustomSet.tag = 'raw';
RawCustomSet.val = {...
  PupilDiameterMin,...
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

InterpUpSampFreq = cfg_entry;
InterpUpSampFreq.name = 'Interpolation upsampling frequency (Hz)';
InterpUpSampFreq.tag = 'interp_upsamplingFreq';
InterpUpSampFreq.num = [1 1];
InterpUpSampFreq.val = {1000};
InterpUpSampFreq.help = {'The upsampling frequency used to generate the smooth signal. (Hz)'};

LPFiltCutoffFreq = cfg_entry;
LPFiltCutoffFreq.name = 'Lowpass filter cutoff frequency (Hz)';
LPFiltCutoffFreq.tag = 'LpFilt_cutoffFreq';
LPFiltCutoffFreq.num = [1 1];
LPFiltCutoffFreq.val = {4};
LPFiltCutoffFreq.help = {'Cutoff frequency of the lowpass filter used during final smoothing. (Hz)'};

LPFiltOrder = cfg_entry;
LPFiltOrder.name = 'Lowpass filter order';
LPFiltOrder.tag = 'LpFilt_order';
LPFiltOrder.num = [1 1];
LPFiltOrder.val = {4};
LPFiltOrder.help = {'Filter order of the lowpass filter used during final smoothing.'};

InterpMaxGap = cfg_entry;
InterpMaxGap.name = 'Interpolation max gap (ms)';
InterpMaxGap.tag = 'interp_maxGap';
InterpMaxGap.num = [1 1];
InterpMaxGap.val = {250};
InterpMaxGap.help = {['Maximum gap in the used (valid) raw samples to interpolate over. ',...
  'Sections that were interpolated over distances larger than this value will be set to NaN. (ms)']};

ValidCustomSet = cfg_branch;
ValidCustomSet.name = 'Settings for valid data preprocessing';
ValidCustomSet.tag = 'valid';
ValidCustomSet.val = {InterpUpSampFreq, LPFiltCutoffFreq, LPFiltOrder, InterpMaxGap};

CustomSet = cfg_branch;
CustomSet.name = 'Custom settings';
CustomSet.tag = 'custom_settings';
CustomSet.val = {RawCustomSet, ValidCustomSet};

DefaultSet = cfg_const;
DefaultSet.name = 'Default settings';
DefaultSet.tag = 'default_settings';
DefaultSet.val = {'Default settings'};

Set = cfg_choice;
Set.name = 'Settings';
Set.tag = 'settings';
Set.values = {DefaultSet, CustomSet};
Set.val = {DefaultSet};
Set.help = {'Define settings to modify preprocessing'};

% define segments
% ------------------------------------------------------
SegStart = cfg_entry;
SegStart.name = 'Segment start (seconds)';
SegStart.tag = 'start';
SegStart.num = [1 1];
SegStart.help = {'Segment start (seconds)'};
SegEnd = cfg_entry;
SegEnd.name = 'Segment end (seconds)';
SegEnd.tag = 'end';
SegEnd.num = [1 1];
SegEnd.help = {'Segment end (seconds)'};
SegName = cfg_entry;
SegName.name = 'Segment name';
SegName.strtype = 's';
SegName.tag = 'name';
SegName.help = {'Segment name'};

Seg = cfg_branch;
Seg.name = 'Segment';
Seg.tag = 'segments';
Seg.val = {SegStart, SegEnd, SegName};

SegRep = cfg_repeat;
SegRep.name = 'Segments';
SegRep.tag = 'segments_rep';
SegRep.values = {Seg};
SegRep.num = [0 Inf];
SegRep.help = {['Define segments to calculate statistics on. These segments will be stored ',...
  'in the output channel and also will be show if plotting is enabled']};

% define plot_data
% ------------------------------------------------------
PlotData = cfg_menu;
PlotData.name = 'Plot data';
PlotData.tag = 'plot_data';
PlotData.values = {true, false};
PlotData.labels = {'True', 'False'};
PlotData.val = {false};
PlotData.help = {'Choose whether to plot the data'};

% Executable branch
% ------------------------------------------------------
PupilPP      = cfg_exbranch;
PupilPP.name = 'Pupil preprocessing';
PupilPP.tag  = 'pupil_preprocess';
PupilPP.val  = {DataFile, Chan, ChanComb, ChanValidCutoff, ChanAct, Set, SegRep, PlotData};
PupilPP.prog = @pspm_cfg_run_pupil_preprocess;
PupilPP.vout = @pspm_cfg_vout_pupil_preprocess;
PupilPP.help = {['Pupil size preprocessing using the steps described in the reference article. The function allows',...
  ' users to preprocess two eyes simultaneously and average them in addition to offering single eye preprocessing.',...
  ' Further, users can define segments on which statistics such as min, max, mean, etc. will be computed. In order to',...
  ' get information about the preprocessing steps, please refer to pupil preprocessing user guide section in PsPM',...
  ' manual for an explanation.'],...
  ['Reference: ',...
  'Kret, Mariska E., and Elio E. Sjak-Shie. "Preprocessing pupil size data: Guidelines and code." ',...
  'Behavior research methods (2018): 1-7.']};
end

function vout = pspm_cfg_vout_pupil_preprocess(~)
vout = cfg_dep;
vout.sname      = 'Output File';
% only cfg_files
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
end
