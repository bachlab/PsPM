function [pupil_pp] = pspm_cfg_pupil_preprocess(job)
    % Matlabbatch function for pspm_pupil_pp
    %__________________________________________________________________________
    % (C) 2019 Eshref Yozdemir (University of Zurich)

    % Initialise
    global settings
    if isempty(settings), pspm_init; end

    % define datafile
    % ------------------------------------------------------
    datafile         = cfg_files;
    datafile.name    = 'Data File';
    datafile.tag     = 'datafile';
    datafile.num     = [1 1];
    datafile.help    = {'Specify the PsPM datafile containing the pupil recordings ', settings.datafilehelp};

    % define channel
    % ------------------------------------------------------
    chan_nr = cfg_entry;
    chan_nr.name = 'Channel number';
    chan_nr.tag  = 'chan_nr';
    chan_nr.num  = [1 1];
    chan_nr.help = {'Enter a channel number'};

    chan_def = cfg_menu;
    chan_def.name = 'Channel definition';
    chan_def.tag = 'chan_def';
    chan_def.values = {'pupil', 'pupil_l', 'pupil_r', 'pupil_c', 'pupil_pp_l', 'pupil_pp_r', 'pupil_pp_c'};
    chan_def.labels = {'Pupil best',...
                        'Pupil left', ...
                        'Pupil right', ...
                        'Pupil combined', ...
                        'Pupil preprocessed left', ...
                        'Pupil preprocessed right', ...
                        'Pupil preprocessed combined'};
    chan_def.val = {'pupil'};
    chan_def.help = {['Choose the channel definition. Only the last channel in the file corresponding to the selection ',...
        'will be corrected.']};

    channel  = cfg_choice;
    channel.name = 'Primary channel to preprocess';
    channel.tag = 'channel';
    channel.values = {chan_def, chan_nr};
    channel.val = {chan_def};
    channel.help = {'Choose the primary channel to preprocess.'};

    % define channel_combine
    % ------------------------------------------------------
    chancomb_def = cfg_menu;
    chancomb_def.name = 'Channel definition';
    chancomb_def.tag = 'chan_def';
    chancomb_def.values = {'none', 'pupil_l', 'pupil_r', 'pupil_pp_l', 'pupil_pp_r'};
    chancomb_def.labels = {'No combining',...
                          'Pupil left',...
                          'Pupil right',...
                          'Pupil preprocessed left',...
                          'Pupil preprocessed right'};
    chancomb_def.val = {'none'};
    chancomb_def.help = {['Choose the channel definition. Only the last channel in the file corresponding to the selection ',...
        'will be used.']};

    channel_combine  = cfg_choice;
    channel_combine.name = 'Secondary channel to preprocess and combine';
    channel_combine.tag = 'channel_combine';
    channel_combine.values = {chancomb_def, chan_nr};
    channel_combine.val = {chancomb_def};
    channel_combine.help = {['Choose the secondary channel to preprocess using the exact same steps. Afterwards this ', ...
        'channel will be combined with primary channel in order to create a preprocessed mean channel. Note that the ', ...
        'recorded eye in secondary channel must be different than the recorded eye in primary channel']};

    % define channel_action
    % ------------------------------------------------------
    channel_action = cfg_menu;
    channel_action.name = 'Channel action';
    channel_action.tag  = 'channel_action';
    channel_action.values = {'add', 'replace'};
    channel_action.labels = {'Add', 'Replace'};
    channel_action.val = {'add'};
    channel_action.help = {'Choose whether to add the corrected channel or replace a previously corrected channel.'};

    % define settings
    % ------------------------------------------------------
    PupilDiameter_Min = cfg_entry;
    PupilDiameter_Min.name = 'Minimum allowed pupil diameter';
    PupilDiameter_Min.tag = 'PupilDiameter_Min';
    PupilDiameter_Min.num = [1 1];
    PupilDiameter_Min.val = {1.5};
    PupilDiameter_Min.help = {'Minimum allowed pupil diameter in the same unit as the pupil channel.'};

    PupilDiameter_Max = cfg_entry;
    PupilDiameter_Max.name = 'Maximum allowed pupil diameter';
    PupilDiameter_Max.tag = 'PupilDiameter_Max';
    PupilDiameter_Max.num = [1 1];
    PupilDiameter_Max.val = {9.0};
    PupilDiameter_Max.help = {'Maximum allowed pupil diameter in the same unit as the pupil channel.'};

    islandFilter_islandSeparation = cfg_entry;
    islandFilter_islandSeparation.name = 'Island separation min distance (ms)';
    islandFilter_islandSeparation.tag = 'islandFilter_islandSeparation_ms';
    islandFilter_islandSeparation.num = [1 1];
    islandFilter_islandSeparation.val = {40};
    islandFilter_islandSeparation.help = {'Minimum distance used to consider samples ''separated'''};

    islandFilter_minIslandWidth_ms = cfg_entry;
    islandFilter_minIslandWidth_ms.name = 'Min valid island width (ms)';
    islandFilter_minIslandWidth_ms.tag = 'islandFilter_minIslandwidth_ms';
    islandFilter_minIslandWidth_ms.num = [1 1];
    islandFilter_minIslandWidth_ms.val = {50};
    islandFilter_minIslandWidth_ms.help = {['Minimum temporal width required to still consider a sample island ',...
        'valid. If the temporal width of the island is less than this value, all the samples ',...
        'in the island will be marked as invalid.']};

    dilationSpeedFilter_MadMultiplier = cfg_entry;
    dilationSpeedFilter_MadMultiplier.name = 'Number of medians in speed filter';
    dilationSpeedFilter_MadMultiplier.tag = 'dilationSpeedFilter_MadMultiplier';
    dilationSpeedFilter_MadMultiplier.num = [1 1];
    dilationSpeedFilter_MadMultiplier.val = {16};
    dilationSpeedFilter_MadMultiplier.help = {'Number of median to use as the cutoff threshold when applying the speed filter'};

    dilationSpeedFilter_maxGap_ms = cfg_entry;
    dilationSpeedFilter_maxGap_ms.name = 'Max gap to compute speed (ms)';
    dilationSpeedFilter_maxGap_ms.tag = 'dilationSpeedFilter_maxGap_ms';
    dilationSpeedFilter_maxGap_ms.num = [1 1];
    dilationSpeedFilter_maxGap_ms.val = {200};
    dilationSpeedFilter_maxGap_ms.help = {'Only calculate the speed when the gap between samples is smaller than this value.'};

    gapDetect_minWidth = cfg_entry;
    gapDetect_minWidth.name = 'Min missing data width (ms)';
    gapDetect_minWidth.tag = 'gapDetect_minWidth';
    gapDetect_minWidth.num = [1 1];
    gapDetect_minWidth.val = {75};
    gapDetect_minWidth.help = {'Minimum width of a missing data section that causes it to be classified as a gap.'};

    gapDetect_maxWidth = cfg_entry;
    gapDetect_maxWidth.name = 'Max missing data width (ms)';
    gapDetect_maxWidth.tag = 'gapDetect_maxWidth';
    gapDetect_maxWidth.num = [1 1];
    gapDetect_maxWidth.val = {2000};
    gapDetect_maxWidth.help = {'Maximum width of a missing data section that causes it to be classified as a gap.'};

    gapPadding_backward = cfg_entry;
    gapPadding_backward.name = 'Reject before missing data (ms)';
    gapPadding_backward.tag = 'gapPadding_backward';
    gapPadding_backward.num = [1 1];
    gapPadding_backward.val = {50};
    gapPadding_backward.help = {'The section right before the start of a gap within which samples are to be rejected.'};

    gapPadding_forward = cfg_entry;
    gapPadding_forward.name = 'Reject after missing data (ms)';
    gapPadding_forward.tag = 'gapPadding_forward';
    gapPadding_forward.num = [1 1];
    gapPadding_forward.val = {50};
    gapPadding_forward.help = {'The section right after the end of a gap within which samples are to be rejected.'};

    residualsFilter_passes = cfg_entry;
    residualsFilter_passes.name = 'Deviation filter passes';
    residualsFilter_passes.tag = 'residualsFilter_passes';
    residualsFilter_passes.num = [1 1];
    residualsFilter_passes.val = {4};
    residualsFilter_passes.help = {'Number of passes deviation filter makes'};

    residualsFilter_MadMultiplier = cfg_entry;
    residualsFilter_MadMultiplier.name = 'Number of medians in deviation filter';
    residualsFilter_MadMultiplier.tag = 'residualsFilter_MadMultiplier';
    residualsFilter_MadMultiplier.num = [1 1];
    residualsFilter_MadMultiplier.val = {16};
    residualsFilter_MadMultiplier.help = {['The multiplier used when defining the threshold. ',...
        'Threshold equals this multiplier times the median.  After each pass, all the input ',...
        'samples that are outside the threshold are removed. Note that all samples (even the ',...
        'ones which may have been rejected by the previous devation filter pass) are considered.']};

    residualsFilter_interpFs = cfg_entry;
    residualsFilter_interpFs.name = 'Butterworth sampling frequency (Hz)';
    residualsFilter_interpFs.tag = 'residualsFilter_interpFs';
    residualsFilter_interpFs.num = [1 1];
    residualsFilter_interpFs.val = {100};
    residualsFilter_interpFs.help = {'Fs for first order Butterworth filter.'};

    residualsFilter_lowpassCF = cfg_entry;
    residualsFilter_lowpassCF.name = 'Butterworth cutoff frequency (Hz)';
    residualsFilter_lowpassCF.tag = 'residualsFilter_interpFs';
    residualsFilter_lowpassCF.num = [1 1];
    residualsFilter_lowpassCF.val = {100};
    residualsFilter_lowpassCF.help = {'Cutoff frequency for first order Butterworth filter.'};

    keepFilterData = cfg_menu;
    keepFilterData.name = 'Store intermediate steps';
    keepFilterData.tag = 'keepFilterData';
    keepFilterData.values = {true, false};
    keepFilterData.labels = {'True', 'False'};
    keepFilterData.val = {false};
    keepFilterData.help = {['If true, intermediate filter data will be stored for plotting. ',...
        'Set to false to save memory and improve plotting performance.']};

    raw_custom_settings = cfg_branch;
    raw_custom_settings.name = 'Settings for raw preprocessing';
    raw_custom_settings.tag = 'raw';
    raw_custom_settings.val = {...
        PupilDiameter_Min,...
        PupilDiameter_Max,...
        islandFilter_islandSeparation,...
        islandFilter_minIslandWidth_ms,...
        dilationSpeedFilter_MadMultiplier,...
        dilationSpeedFilter_maxGap_ms,...
        gapDetect_minWidth,...
        gapDetect_maxWidth,...
        gapPadding_backward,...
        gapPadding_forward,...
        residualsFilter_passes,...
        residualsFilter_MadMultiplier,...
        residualsFilter_interpFs,...
        residualsFilter_lowpassCF,...
        keepFilterData...
    };

    interp_upsamplingfreq = cfg_entry;
    interp_upsamplingfreq.name = 'Interpolation upsampling frequency (Hz)';
    interp_upsamplingfreq.tag = 'interp_upsamplingFreq';
    interp_upsamplingfreq.num = [1 1];
    interp_upsamplingfreq.val = {1000};
    interp_upsamplingfreq.help = {'The upsampling frequency used to generate the smooth signal. (Hz)'};

    lpfilt_cutofffreq = cfg_entry;
    lpfilt_cutofffreq.name = 'Lowpass filter cutoff frequency (Hz)';
    lpfilt_cutofffreq.tag = 'LpFilt_cutoffFreq';
    lpfilt_cutofffreq.num = [1 1];
    lpfilt_cutofffreq.val = {4};
    lpfilt_cutofffreq.help = {'Cutoff frequency of the lowpass filter used during final smoothing. (Hz)'};

    lpfilt_order = cfg_entry;
    lpfilt_order.name = 'Lowpass filter order';
    lpfilt_order.tag = 'LpFilt_order';
    lpfilt_order.num = [1 1];
    lpfilt_order.val = {4};
    lpfilt_order.help = {'Filter order of the lowpass filter used during final smoothing.'};

    interp_maxgap = cfg_entry;
    interp_maxgap.name = 'Interpolation max gap (ms)';
    interp_maxgap.tag = 'interp_maxGap';
    interp_maxgap.num = [1 1];
    interp_maxgap.val = {250};
    interp_maxgap.help = {['Maximum gap in the used (valid) raw samples to interpolate over. ',...
        'Sections that were interpolated over distances larger than this value will be set to NaN. (ms)']};

    valid_custom_settings = cfg_branch;
    valid_custom_settings.name = 'Settings for valid data preprocessing';
    valid_custom_settings.tag = 'valid';
    valid_custom_settings.val = {interp_upsamplingfreq, lpfilt_cutofffreq, lpfilt_order, interp_maxgap};

    custom_settings = cfg_branch;
    custom_settings.name = 'Custom settings';
    custom_settings.tag = 'custom_settings';
    custom_settings.val = {raw_custom_settings, valid_custom_settings};

    default_settings = cfg_const;
    default_settings.name = 'Default settings';
    default_settings.tag = 'default_settings';
    default_settings.val = {'Default settings'};

    sett = cfg_choice;
    sett.name = 'Settings';
    sett.tag = 'settings';
    sett.values = {default_settings, custom_settings};
    sett.val = {default_settings};
    sett.help = {'Define settings to modify preprocessing'};

    % define segments
    % ------------------------------------------------------
    segment_start = cfg_entry;
    segment_start.name = 'Segment start (seconds)';
    segment_start.tag = 'start';
    segment_start.num = [1 1];
    segment_start.help = {'Segment start (seconds)'};
    segment_end = cfg_entry;
    segment_end.name = 'Segment end (seconds)';
    segment_end.tag = 'end';
    segment_end.num = [1 1];
    segment_end.help = {'Segment end (seconds)'};
    segment_name = cfg_entry;
    segment_name.name = 'Segment name';
    segment_name.strtype = 's';
    segment_name.tag = 'name';
    segment_name.help = {'Segment name'};

    segments = cfg_branch;
    segments.name = 'Segment';
    segments.tag = 'segments';
    segments.val = {segment_start, segment_end, segment_name};

    segments_rep = cfg_repeat;
    segments_rep.name = 'Segments';
    segments_rep.tag = 'segments_rep';
    segments_rep.values = {segments};
    segments_rep.num = [0 Inf];
    segments_rep.help = {['Define segments to calculate statistics on. These segments will be stored ',...
        'in the output channel and also will be show if plotting is enabled']};

    % define plot_data
    % ------------------------------------------------------
    plot_data = cfg_menu;
    plot_data.name = 'Plot data';
    plot_data.tag = 'plot_data';
    plot_data.values = {true, false};
    plot_data.labels = {'True', 'False'};
    plot_data.val = {false};
    plot_data.help = {'Choose whether to plot the data'};

    % Executable branch
    % ------------------------------------------------------
    pupil_pp      = cfg_exbranch;
    pupil_pp.name = 'Pupil preprocessing';
    pupil_pp.tag  = 'pupil_preprocess';
    pupil_pp.val  = {datafile, channel, channel_combine, channel_action, sett, segments_rep, plot_data};
    pupil_pp.prog = @pspm_cfg_run_pupil_preprocess;
    pupil_pp.vout = @pspm_cfg_vout_pupil_preprocess;
    pupil_pp.help = {['Pupil size preprocessing using the steps described in the reference article. The function allows',...
        ' users to preprocess two eyes simultaneously and average them in addition to offering single eye preprocessing.',...
        ' Further, users can define segments on which statistics such as min, max, mean, etc. will be computed. In order to',...
        ' get information about the preprocessing steps, please refer to pupil preprocessing user guide section in PsPM',...
        ' manual for an explanation.'],...
        ['Reference: ',...
        'Kret, Mariska E., and Elio E. Sjak-Shie. "Preprocessing pupil size data: Guidelines and code." ',...
        'Behavior research methods (2018): 1-7.']};
end

function vout = pspm_cfg_vout_pupil_preprocess(job)
    vout = cfg_dep;
    vout.sname      = 'Output File';
    % only cfg_files
    vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
    vout.src_output = substruct('()',{':'});
end
