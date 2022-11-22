function options = pspm_options(options, FunName)
% ● Definition
%   pspm_options automatically determine the fields of options for the
%   corresponding function.
% ● Arguments
%   options:  a struct to be filled by the function
%   FunName:  a string, the name of the function where option is used
% ● Copyright
%   Introduced in PsPM 6.1
%   Written in 2022 by Teddy Chao (UCL)

%% 0 Initialise
global settings
if isempty(settings)
  pspm_init;
end
if ~isstruct(options)
  warning('ID:invalid_input', 'Options must be a struct.');
  options = struct();
  options.invalid = 1;
  return
else
  if isempty(options) && ~isempty(fieldnames(options))
    warning('ID:invalid_input', 'options has fields with unspecified values.');
    options = struct();
    options.invalid = 1;
    return
  end
end
options.invalid = 0;


%% 1 Text
text_optional_channel_invalid = 'options.channel must contain valid channel types or positive integers.';
text_optional_channel_invalid_char = 'options.channel is not a valid channel type.';

%% 2 Main Processing
switch FunName
  case 'blink_saccade_filt'
    %% 2.1 pspm_blink_saccade_filt
    options = autofill(options, 'channel',                0,          '@anynumeric'     );
    options = autofill_channel_action(options);
  case 'compute_visual_angle_core'
    %% 2.2 pspm_compute_visual_angle_core
    options = autofill(options, 'interpolate',            0,          1                 );
  case 'compute_visual_angle'
    %% 2.3 pspm_compute_visual_angle
    options = autofill(options, 'eyes',                   settings.lateral.char.b,...
                                                          {settings.lateral.char.l,...
                                                          settings.lateral.char.r}      );
    options = autofill_channel_action(options);
  case 'con1'
    %% 2.4 pspm_con1
    options = autofill(options, 'zscored',                0,          1                 );
  case 'con2'
    %% 2.5 pspm_con2
    options = autofill_channel_action(options);
  case 'convert_area2diameter'
    %% 2.6 pspm_convert_area2diameter
    options = autofill_channel_action(options);
  case 'convert_au2unit'
    %% 2.7 pspm_convert_au2unit
    options = autofill_channel_action(options);
  case 'convert_ecg2hb'
    %% 2.8 pspm_convert_ecg2hb
    options = autofill_channel_action(options, 'replace');
    options = autofill(options, 'debugmode',              0,          1                 ); % can be merged into development mode?
    options = autofill(options, 'semi',                   0,          1                 ); % semi==1 will pop a dialog
    options = autofill(options, 'maxHR',                  200,        '>', 20           ); % field: maxHR (bpm)
    options = autofill(options, 'minHR',                  20,         '<', 200          ); % field: minHR (bpm)
    options = autofill(options, 'twthresh',               0.36,       '@anynumeric'     );
    options = autofill(options, 'outfact',                2,          '@anynumeric'     );
    if options.maxHR < options.minHR
      warning('ID:invalid_input', ...
        ['''options.minHR'' and ''options.maxHR'' ', ...
        'must be numeric and ''options.minHR'' must be ', ...
        'smaller than ''options.maxHR''']);
      options.invalid = 1;
      return
    end
  case 'convert_ecg2hb_amri'
    %% 2.9 pspm_convert_ecg2hb_amri
    options = autofill(options, 'channel',                'ecg'                         );
    options = autofill(options, 'signal_to_use',          'auto',   {'ecg', 'teo'}      );
    options = autofill(options, 'hrrange',                [20 200], '>', 0              );
    options = autofill(options, 'ecg_bandpass',           [0.5 40], '>', 0              );
    options = autofill(options, 'teo_bandpass',           [8 40],   '>', 0              );
    options = autofill(options, 'teo_order',              1,        '>', 0              );
    options = autofill(options, 'min_cross_corr',         0.5,      '@anynumeric'       );
    options = autofill(options, 'min_relative_amplitude', 0.4,      '@anynumeric'       );
    options = autofill_channel_action(options);
  case 'convert_gaze_distance'
    %% 2.10 pspm_convert_gaze_distance
    options = autofill_channel_action(options);
  case 'convert_hb2hp'
    %% 2.11 pspm_convert_hb2hp
    options = autofill_channel_action(options, 'replace');
    options = autofill(options, 'limit.lower',            0.2,      '@anynumeric'       );
    options = autofill(options, 'limit.upper',            2,        '@anynumeric'       );
  case 'convert_pixel2unit'
    %% 2.12 pspm_convert_pixel2unit
    options = autofill_channel_action(options);
  case 'convert_ppg2hb'
    %% 2.13 pspm_convert_ppg2hb
    options = autofill_channel_action(options, 'replace');
    options = autofill(options, 'channel',                'ppg2hb', '@anychar'          );
    options = autofill(options, 'diagnostics',            0,        1                   );
    options = autofill(options, 'lsm',                    0                             );
  case 'convert_visangle2sps'
    %% 2.14 pspm_convert_visangle2sps
    options = autofill_channel_action(options);
    options = autofill(options, 'channels',               0,        '@anynumeric'       );
    options = autofill(options, 'eye',                    settings.lateral.char.b, ...
                                                          {settings.lateral.char.r, ...
                                                          settings.lateral.char.l}      );
  case 'data_editor'
    %% 2.15 pspm_data_editor
    % output_file does not have a default value
    % epoch_file does not have a default value
    options = autofill(options, 'overwrite',              0,        [1, 2]);
  case 'dcm'
    %% 2.16 pspm_dcm
    options = autofill(options, 'indrf',                  0,        '@anynumeric'       ); % Estimate the response function from the data
    options = autofill(options, 'getrf',                  0,        '@anynumeric'       ); % only estimate RF, do not do trial-wise DCM
    options = autofill(options, 'rf',                     0,        '@anynumeric'       ); % Call an external file to provide response function (for use when this is previously estimated by pspm_get_rf)
    options = autofill(options, 'nosave',                 0,        '@anynumeric'       ); % Don't save dcm structure (e.g. used by pspm_get_rf)
    options = autofill(options, 'depth',                  2,        '@anynumeric'       ); % no of trials to invert at the same time
    options = autofill(options, 'aSCR_sigma_offset',      0.1,      '@anynumeric'       ); % minimum dispersion (standard deviation) for flexible responses (second)
    options = autofill(options, 'sclpre',                 2,        '@anynumeric'       ); % scl-change-free window before first event (second)
    options = autofill(options, 'sclpost',                5,        '@anynumeric'       ); % scl-change-free window after last event (second)
    options = autofill(options, 'sfpre',                  2,        '@anynumeric'       ); % sf-free window before first event (second)
    options = autofill(options, 'sfpost',                 5,        '@anynumeric'       ); % sf-free window after last event (second)
    options = autofill(options, 'sffreq',                 0.5,      '@anynumeric'       ); % maximum frequency of SF in ITIs (Hz)
    options = autofill(options, 'method',                 'dcm'                         );
    options = autofill(options, 'dispwin',                1,        '@anynumeric'       );
    options = autofill(options, 'dispsmallwin',           0,        '@anynumeric'       );
    options = autofill(options, 'crfupdate',              0,        '@anynumeric'       ); % update CRF priors to observed SCRF, or use pre-estimated priors
    options = autofill(options, 'eventnames',           	{}                            ); % Cell array of names for individual events
    options = autofill(options, 'trlnames',               {}                            ); % Cell array of names for individual trials, is used for contrast manager only (e.g. condition descriptions)
    options = autofill(options, 'overwrite',              1,        [0, 2]              );
  case 'dcm_inv'
    %% 2.17 pspm_dcm_inv
    options = autofill(options, 'eSCR',                   0,        '@anynumeric'       ); % contains the data to estimate RF from
    options = autofill(options, 'aSCR_sigma_offset',      0.1,      '@anynumeric'       ); % minimum dispersion (standard deviation) for flexible responses (second)
    options = autofill(options, 'aSCR',                   0,        '@anynumeric'       ); % contains the data to adjust the RF to
    options = autofill(options, 'meanSCR',                0,        '@anynumeric'       ); % data to adjust the response amplitude priors to
    options = autofill(options, 'depth',                  2,        '@anynumeric'       ); % no of trials to invert at the same time
    options = autofill(options, 'dispsmallwin',           0,        '@anynumeric'       );
    options = autofill(options, 'dispwin',                1,        '@anynumeric'       );
    options = autofill(options, 'sfpre',                  2,        '@anynumeric'       ); % sf-free window before first event (second)
    options = autofill(options, 'sfpost',                 5,        '@anynumeric'       ); % sf-free window after last event (second)
    options = autofill(options, 'sffreq',                 0.5,      '@anynumeric'       ); % maximum frequency of SF in ITIs (Hz)
    options = autofill(options, 'sclpre',                 2.5,      '@anynumeric'       ); % scl-change-free window before first event, avoid overlap of last SCL change with next trial (second)
    options = autofill(options, 'sclpost',                2,        '@anynumeric'       ); % scl-change-free window after last event (second)
    options = autofill(options, 'crfupdate',              0,        '@anynumeric'       ); % update CRF priors to observed SCRF, or use pre-estimated priors, default to use pre-estimated priors
    options = autofill(options, 'getrf',                  0,        '@anynumeric'       ); % only estimate RF, do not do trial-wise DCM
    options = autofill(options, 'overwrite',              1,        [0, 2]              );
    % options = autofill(options, 'fixevents', ?); % fixed events to adjust amplitude priors
    % options = autofill(options, 'flexevents', ?); % flexible events to adjust amplitude priors
    % options = autofill(options, 'missing', ?); % data points to be disregarded by inversion
    % options = autofill(options, 'rf', ?); % use pre-specified RF, provided in file, or as 4-element vector in log parameter space
  case 'down'
    %% 2.18 pspm_down
    options = autofill(options, 'overwrite',              1,        [0, 2]              );
  case 'emg_pp'
    %% 2.19 pspm_emg_pp
    options = autofill(options, 'channel',                'emg',    '@anychar'          );
    options = autofill(options, 'mains_freq',             50,       '@anynumeric'       );
    options = autofill_channel_action(options,            'replace','add'               );
  case 'exp'
    %% 2.20 pspm_exp
    options = autofill(options, 'target',                 'screen', '@anychar'          );
    options = autofill(options, 'statstype',              'param',  {'cond', 'recon'}   );
    options = autofill(options, 'delim',                  '\t'                          );
    options = autofill(options, 'exclude_missing',        0,        1                   );
  case 'extract_segments'
    %% 2.21 pspm_extract_segments
    options = autofill(options, 'norm',                   0,        1                   );
    options = autofill(options, 'plot',                   0,        1                   );
    options = autofill(options, 'overwrite',              0,        [1, 2]              );
    options = autofill(options, 'length',                 -1,       '@anynumeric'       );
    options = autofill(options, 'outputfile',             '',       '@anychar'          );
    options = autofill(options, 'timeunit',               'seconds',{'seconds', ...
                                                                    'samples',...
                                                                    'markers'}          );
    options = fill_extract_segments(options);
  case 'find_sounds'
    %% pspm_find_sounds
    options = autofill_channel_action(options,            'none',   {'add','replace'}   );
    options = autofill(options, 'channel_output',         'all',    'corrected'         );
    options = autofill(options, 'diagnostics',            1,        0                   );
    options = autofill(options, 'maxdelay',               3,        '>=',  0            );
    options = autofill(options, 'mindelay',               0,        '>=',  0            );
    options = autofill(options, 'threshold',              0.1,      '>=',  0            );
    options = autofill(options, 'sndchannel',             0,        '@anyinteger'       );
    options = autofill(options, 'trigchannel',            0,        '@anyinteger'       );
    options = autofill(options, 'resample',               1,        '@anyinteger'       );
    options = autofill(options, 'plot',                   0,        1                   );
    options = autofill(options, 'snd_in_snd',             0,        1                   );
    options = autofill(options, 'expectedSoundCount',     0,        '@anyinteger'       );
    options = fill_find_sounds(options);
  case 'find_valid_fixations'
    %% 2.21 pspm_find_valid_fixations
    options = autofill_channel_action(options);
    options = autofill(options, 'missing',                0,        1                   );
    options = autofill(options, 'newfile',                '',       '@anychar'          );
    options = autofill(options, 'plot_gaze_coords',       0,        1                   );
    options = autofill(options, 'eyes',                   settings.lateral.full.c, ...
                                                          {settings.lateral.full.l, ...
                                                          settings.lateral.full.r}      );
    options = fill_find_valid_fixations(options);
  case 'gaze_pp'
    %% 2.22 pspm_gaze_pp
    options = autofill(options, 'channel',                'gaze_x_l',{'gaze_x_r',...
                                                                    'gaze_y_l',...
                                                                    'gaze_y_r'}         );
    options = autofill(options, 'channel_combine',        'none',   {'gaze_x_l',...
                                                                    'gaze_x_r',...
                                                                    'gaze_y_l',...
                                                                    'gaze_y_r'}         );
    options = autofill(options, 'segments',               {}                            );
    options = autofill(options, 'valid_sample',           0,        1                   );
    options = autofill(options, 'plot_data',              false                         );
    options = autofill_channel_action(options,            'add',    {'replace',...
                                                                    'none'}             );
  case 'get_markerinfo'
    %% 2.23 pspm_get_markerinfo
    options = autofill(options, 'markerchan',             -1,       '@anyinteger'       );
    options = autofill(options, 'filename',               '',       '@anychar'          );
    options = autofill(options, 'overwrite',              0,        [1, 2]              );
  case 'get_rf'
    %% 2.24 pspm_get_rf
    options = autofill(options, 'getrf',                  1                             );
    options = autofill(options, 'nosave',                 1,        0                   );
  case 'glm'
    %% 2.25 pspm_glm
    options = autofill(options, 'modelspec',              'scr'                         );
    options = autofill(options, 'bf',                     0,        1                   );
    options = autofill(options, 'overwrite',              0,        [1, 2]              );
    options = autofill(options, 'norm',                   0,        1                   );
    options = autofill(options, 'centering',              1,        0                   );
    options = fill_glm(options);
  case 'import'
    %% 2.26 pspm_import
    options = autofill(options, 'overwrite',              0,        [1, 2]              );
  case 'interpolate'
    %% 2.27 pspm_interpolate
    options = autofill_channel_action(options);
    options = autofill(options, 'overwrite',              0,        [1, 2]              );
    options = autofill(options, 'method',                 'linear', {'pchip',...
                                                                    'nearest', ...
                                                                    'spline', ...
                                                                    'previous', ...
                                                                    'next'}             );
    options = autofill(options, 'extrapolate',            0,        1                   );
    options = autofill(options, 'newfile',                0,        1                   );
    %options = autofill(options, 'channels',              []                            );
  case 'load1'
    %% 2.28 pspm_load1
    options = autofill(options, 'overwrite',              0,        [1, 2]              );
    options = autofill(options, 'zscored',                0,        1                   );
  case 'merge'
    %% 2.29 pspm_merge
    options = autofill(options, 'marker_chan_num',        [0 0],    '@anynumeric'       );
    options = autofill(options, 'overwrite',              0,        [1, 2]              );
  case 'pfm'
    %% 2.30 pspm_pfm
    options = autofill(options, 'overwrite',              0,        [1, 2]              );
  case 'pp'
    %% 2.31 pspm_pp
    options = autofill(options, 'overwrite',              0,        [1, 2]              );
  case 'process_illuminance'
    %% 2.32 pspm_process_illuminance
    options = autofill(options, 'overwrite',              0,        [1, 2]              );
    options = autofill(options, 'transfer',[49.79,-1.05,-0.50],     '@anynumeric'       );
    options = autofill(options, 'bf',                     struct(), '@anystruct'        );
    options = autofill(options, 'fn',                     '',       '@anychar'          );
    options.bf = autofill(options.bf,   'duration',       20,       '>=',  0            );
    options.bf = autofill(options.bf,   'offset',         0.2,      '>=',  0            );
    options.bf = autofill(options.bf,   'dilation',       struct(), '@anystruct'        );
    options.bf = autofill(options.bf,   'constriction',   struct(), '@anystruct'        );
    options.bf.dilation     = autofill(options.bf.dilation,     'fhandle', @pspm_bf_ldrf_gm);
    options.bf.constriction = autofill(options.bf.constriction, 'fhandle', @pspm_bf_lcrf_gm);
  case 'pupil_correct_eyelink'
    %% 2.33 pspm_pupil_correct_eyelink
    options = autofill_channel_action(options);
    options = autofill(options, 'mode',                   'auto',   'manual'            );
    options = autofill(options, 'C_x',                    0,        '@anynumeric'       );
    options = autofill(options, 'C_y',                    0,        '@anynumeric'       );
    options = autofill(options, 'C_z',                    0,        '@anynumeric'       );
    options = autofill(options, 'S_x',                    0,        '@anynumeric'       );
    options = autofill(options, 'S_y',                    0,        '@anynumeric'       );
    options = autofill(options, 'S_z',                    0,        '@anynumeric'       );
    options = autofill(options, 'channel',                'pupil',  '@anychar'          );
    % screen_size_mm
    % screen_size_px
  case 'pupil_pp'
    %% 2.34 pspm_pupil_pp
    options = autofill_channel_action(options);
    options = autofill(options, 'channel',                'pupil',  '@anychar'          );
    options = autofill(options, 'channel_combine',        'none',   '@anychar'          );
    options = autofill(options, 'plot_data',              0,        1                   );
    options = autofill(options, 'segments',               {},       '@anycell'          );
  case 'remove_epochs'
    %% 2.35 pspm_remove_epochs
    options = autofill_channel_action(options);
  case 'resp_pp'
    %% 2.36 pspm_resp_pp
    options = autofill_channel_action(options);
    options = autofill(options, 'systemtype',             'bellows','cushion'           );
    options = autofill(options, 'plot',                   0,        1                   );
    options = autofill(options, 'diagnostics',            0,        1                   );
    options = autofill(options, 'datatype', {'rp', 'ra', 'rfr', 'rs', 'all'},...
                                                                    '@anysubset'        );
  case 'scr_pp'
    %% 2.37 pspm_scr_pp
    options = autofill_channel_action(options,            'add',    {'replace', ...
                                                                    'withdraw'}         );
    options = autofill(options, 'min',                    0.05,     '@anynumeric'       );
    options = autofill(options, 'max',                    60,       '@anynumeric'       );
    options = autofill(options, 'slope',                  10,       '@anynumeric'       );
    options = autofill(options, 'deflection_threshold',   0.1,      '@anynumeric'       );
    options = autofill(options, 'expand_epochs',          0.5,      '>=', 0             );
    options = autofill(options, 'clipping_step_size',     2,        '@anyinteger'       );
    options = autofill(options, 'clipping_n_window',      10000,    '@anyinteger'       );
    options = autofill(options, 'clipping_threshold',     0.1,      '@anynumeric'       );
    options = autofill(options, 'change_data',            1,        0                   );
    options = autofill(options, 'data_island_threshold',  0,        '>=', 0             );
    options = autofill(options, 'missing_epochs_filename','missing_epochs_filename',...
                                                                    '@anychar'          );
  case 'segment_mean'
    % 2.38 pspm_segment_mean
    options = autofill(options, 'overwrite',              0,        [1, 2]              );
    options = autofill(options, 'newfile',               '',        '@anychar'          );
    options = autofill(options, 'plot',                   0,        1                   );
    options = autofill(options, 'adjust_method',     'none',        {'downsample', ...
                                                                    'interpolate'}      );
  case 'sf'
    %% 2.39 pspm_sf
    options = autofill(options,'overwrite',               1,        [0, 2]              );
    options = autofill(options,'marker_chan_num',         0,        '@anyinteger'       );
    options = autofill(options,'threshold',               0.1,      '>', 0              );
    options = autofill(options,'theta',                   [0.923581, ...
                                                          3.921034, ...
                                                          2.159389, ...
                                                          1.5339, ...
                                                          1.6411756741, ...
                                                          ],        '@anynumeric'       );
    options = autofill(options,'fresp',                   0.5,      '>=', 0             );
    options = autofill(options,'dispwin',                 1,        0                   );
    options = autofill(options,'dispsmallwin',            0,        1                   );
  case 'sf_dcm'
    % 2.40 pspm_sf_dcm
    options = autofill(options,'dispwin',                 1,        0                   );
    options = autofill(options,'dispsmallwin',            0,        1                   );
    options = autofill(options,'fresp',                 0.5,        '>', 0              );
    options = autofill(options,'threshold',             0.1,        '>', 0              );
  case 'sf_mp'
    % 2.41 pspm_sf_mp
    options = autofill(options,'diagnostics',             0,        1                   );
    options = autofill(options,'dispwin',                 0,        1                   );
    options = autofill(options,'threshold',             0.1,        '>', 0              );
    options = autofill(options,'fresp',                 0.5,        '>', 0              );
    options = autofill(options,'theta',                   [0.923581, ...
                                                          3.921034, ...
                                                          2.159389, ...
                                                          1.5339, ...
                                                          1.6411756741, ...
                                                          ],        '@anynumeric'       );
  case 'split_sessions'
    %% 2.42 pspm_split_sessions
    options = autofill(options, 'overwrite',              0,        [1, 2]              );
    options = autofill(options, 'prefix',                 0,        '>=', 0             );
    options = autofill(options, 'suffix',                 0,        '>=', 0             );
    options = autofill(options, 'verbose',                1,        0                   );
    options = autofill(options, 'splitpoints',           [],        '@anynumeric'       );
    options = autofill(options, 'missing',                0,        '@anychar'          );
    options = autofill(options, 'randomITI',              0,        1                   );
    options = autofill(options, 'max_sn',                 settings.split.max_sn,...
                                                                    '>', 0              ); % maximum number of sessions (default 10)
    options = autofill(options, 'min_break_ratio',        settings.split.min_break_ratio,...
                                                                    '>', 0              ); % minimum ratio of session break to normal inter marker interval (default 3)
  case 'trim'
    %% 2.43 pspm_trim
    options = autofill(options, 'overwrite',              0,        [1, 2]              );
    options = autofill(options, 'marker_chan_num',        0,        '@anyinteger'       );
    options = autofill(options, 'drop_offset_markers',    0,        '@anyinteger'       );
  case 'write_channel'
    %% 2.44 pspm_write_channel
    options = autofill(options, 'delete',            'last',        {'first','all'}     );
    if ~isfield('options','msg')
      options.msg = '';
    else
      if ~ischar(options.msg) && ~isstruct(options.msg)
        warning('ID:invalid_input', 'options.msg must be a char or a struct.');
        options.invalid = 1;
        return
      end
    end
    options = autofill(options, 'prefix', 'Generic undocumented operation :: ',...
                                                                    '@anychar'          );
    if ~isfield(options, 'channel')
      options.channel = 0;
    else
      switch class(options.channel)
        case 'char'
          if ~any(strcmpi(options.channel,{settings.channeltypes.type}))
            warning('ID:invalid_input', text_optional_channel_invalid_char);
            options.invalid = 1;
            return
          end
        case 'double'
          if (any(mod(options.channel, 1)) || any(options.channel<0))
            warning('ID:invalid_input', text_optional_channel_invalid);
            options.invalid = 1;
            return
          end
        otherwise
          warning('ID:invalid_input', text_optional_channel_invalid);
          options.invalid = 1;
          return
      end
    end
end
end

function options = autofill(varargin)
switch nargin
  case 3
    options = varargin{1};
    field_name = varargin{2};
    default_value = varargin{3};
    if ~isfield(options, field_name)
      options.(field_name) = default_value;
    else
      if ~strcmp(class(default_value),class(options.(field_name)))
        flag_is_allowed_value = 0;
      else
        switch class(default_value)
          case 'double'
            if isempty(default_value)
              flag_is_allowed_value = isempty(options.(field_name));
            else
              flag_is_allowed_value = any(options.(field_name) == default_value);
            end
          case 'char'
            flag_is_allowed_value = strcmp(options.(field_name), default_value);
          case 'cell'
            flag_is_allowed_value = isequal(options.(field_name), default_value);
        end
      end
      if ~flag_is_allowed_value
        allowed_values_message = generate_allowed_values_message(default_value);
        warning('ID:invalid_input', ['options.', field_name, ' is invalid. ',...
          allowed_values_message]);
        options.invalid = 1;
        return
      end
    end
  case 4
    options = varargin{1};
    field_name = varargin{2};
    default_value = varargin{3};
    optional_value = varargin{4};
    if ~isfield(options, field_name)
      options.(field_name) = default_value;
    else
      if ~strcmp(class(default_value),class(options.(field_name)))
        if (isnumeric(default_value) && islogical(options.(field_name))) || ...
            (islogical(default_value) && isnumeric(options.(field_name)))
          flag_is_allowed_value = 1;
        else
          flag_is_allowed_value = 0;
        end
      else
        switch class(optional_value)
          case 'double'
            if length(default_value) ~= length(options.(field_name))
              flag_is_allowed_value = 0;
            else
              allowed_value = [optional_value, default_value];
              truetable = options.(field_name) == allowed_value;
              flag_is_allowed_value = any(sum(truetable,2));
            end
          case 'char'
            if strcmp(optional_value, '@anychar')
              flag_is_allowed_value = ischar(options.(field_name));
            elseif strcmp(optional_value, '@anynumeric')
              flag_is_allowed_value = isnumeric(options.(field_name));
            elseif strcmp(optional_value, '@anycell')
              flag_is_allowed_value = iscell(options.(field_name));
            elseif strcmp(optional_value, '@anyinteger')
              flag_is_allowed_value = isnumeric(options.(field_name)) && ...
                (options.(field_name)>0) && (mod(options.(field_name), 1)==0);
            elseif strcmp(optional_value, '@anystruct')
              flag_is_allowed_value = isstruct(options.(field_name));
            elseif strcmp(optional_value, '@anysubset')
              flag_is_allowed_value = prod(ismember(options.datatype,default_value),'all');
            elseif strcmp(optional_value, '@any')
              flag_is_allowed_value = true;
            else
              allowed_value = {optional_value, default_value};
              flag_is_allowed_value = strcmp(options.(field_name), allowed_value);
            end
          case 'cell'
            allowed_value = optional_value;
            allowed_value{end+1} = default_value;
            flag_is_allowed_value = strcmp(options.(field_name), allowed_value);
        end
      end
      if ~flag_is_allowed_value
        allowed_values_message = generate_allowed_values_message(default_value, optional_value);
        warning('ID:invalid_input', ['options.', field_name, ' has an invalid value. ',...
          allowed_values_message]);
        options.invalid = 1;
        return
      end
    end
  case 5
    options = varargin{1};
    field_name = varargin{2};
    default_value = varargin{3};
    range_marker = varargin{4};
    optional_value_boundary = varargin{5};
    if ~isfield(options, field_name)
      options.(field_name) = default_value;
    else
      if ~strcmp(class(default_value),class(options.(field_name)))
        flag_is_allowed_value = 0;
      else
        switch class(optional_value_boundary)
          case 'double'
            if length(default_value) ~= length(options.(field_name))
              flag_is_allowed_value = 0;
            else
              switch range_marker
                case '>' % larger than some value
                  flag_is_allowed_value = options.(field_name) > optional_value_boundary;
                case 'integer>' % integer larger than some value
                  flag_is_allowed_value = ...
                    (options.(field_name) > optional_value_boundary) &&...
                    (floor(options.(field_name))==options.(field_name));
                case '>='
                  flag_is_allowed_value = ...
                    options.(field_name) >= optional_value_boundary;
                case 'integer>='
                  flag_is_allowed_value = ...
                    (options.(field_name) >= optional_value_boundary) && ...
                    (floor(options.(field_name))==options.(field_name));
                case '<'
                  flag_is_allowed_value = options.(field_name) < optional_value_boundary;
                case 'integer<'
                  flag_is_allowed_value = ...
                    (options.(field_name) < optional_value_boundary) && ...
                    (floor(options.(field_name))==options.(field_name));
                case '<='
                  flag_is_allowed_value = ...
                    options.(field_name) <= optional_value_boundary;
                case 'integer<='
                  flag_is_allowed_value = ...
                    (options.(field_name) <= optional_value_boundary) && ...
                    (floor(options.(field_name))==options.(field_name));
                otherwise
                  warning('ID:invalid_input', 'range_marker must be <, >, <=, or >=.');
                  options.invalid = 1;
                  return
              end
            end
          otherwise
            warning('ID:invalid_input', ...
              'optional_value_boundary must be a double value for using ranges.');
            options.invalid = 1;
            return
        end
      end
      if ~flag_is_allowed_value
        allowed_values_message = generate_allowed_values_message(default_value, optional_value_boundary, range_marker);
        warning('ID:invalid_input', ['options.', field_name, ' has an invalid value. ',...
          allowed_values_message]);
        options.invalid = 1;
        return
      end
    end
  otherwise
    warning('ID:invalid_input', 'autofill needs at least 3 arguments');
    options.invalid = 1;
    return
end
end

function options = autofill_channel_action(options, varargin)
% Description: subfunction of pspm_options for autofill channel actions
% Usage: (1) use only the variable options if the default channel option is
% 'add' (2) use two variables and the latter as the default channel option
% other than 'add' (3) use three variables where the second is the default
% channel action and the third variable is the list of optional/acceptable
% channel actions.
% Written by Teddy in 2022.
switch nargin
  case 1
    default_value = 'add';
    optional_value = {'add', 'replace'};
  case 2
    default_value = varargin{1};
    optional_value = {'add', 'replace'};
  case 3
    default_value = varargin{1};
    optional_value = varargin{2};
end
if ~isfield(options, 'channel_action')
  options.channel_action = default_value;
else
  acceptable_values = optional_value;
  acceptable_values(2:end+1) = acceptable_values(1:end);
  acceptable_values{1} = default_value;
  if ~any(strcmpi(options.channel_action, acceptable_values))
    allowed_values_message = generate_allowed_values_message(default_value, optional_value);
    warning('ID:invalid_input', ...
      ['''options.channel_action'' must have an accepted value. '...
      allowed_values_message]);
    options.invalid = 1;
    return
  end
end
end

function allowed_values_message = generate_allowed_values_message(varargin)
switch nargin
  case 1
    default_value = varargin{1};
    if isnumeric(default_value)
      default_value_message = num2str(default_value);
    elseif iscell(default_value) && isempty(default_value)
      default_value_message = '{}';
    else
      default_value_message = default_value;
    end
    allowed_values_message = ['The only allowed value is "', default_value_message, '".'];
  case 2
    default_value = varargin{1};
    optional_value = varargin{2};
    switch class(default_value)
      case 'double'
        default_value_converted = num2str(default_value);
      case 'char'
        default_value_converted = default_value;
      case 'cell'
        default_value_converted = default_value{1};
    end
    default_value_message = ['"', default_value_converted,'", '];
    switch class(optional_value)
      case 'double'
        switch length(optional_value)
          case 1
            optional_value_message = [' and "', num2str(optional_value), '"'];
          case 2
            optional_value_message = [', "', num2str(optional_value(1)), '"', ...
              ', and "', num2str(optional_value(2)), '"'];
          case 3
            optional_value_message = [', "', num2str(optional_value(1)), '"', ...
              ', "', num2str(optional_value(2)), '"', ...
              ', and "', num2str(optional_value(3)), '"'];
        end
      case 'char'
        optional_value_message = [' and "', optional_value, '"'];
      case 'cell'
        switch length(optional_value)
          case 1
            optional_value_message = [' and "', optional_value{1}, '"'];
          case 2
            optional_value_message = [', "', optional_value{1}, '"', ...
              ', and "', optional_value{2}, '"'];
          case 3
            optional_value_message = [', "', optional_value{1}, '"', ...
              ', "', optional_value{2}, '"', ...
              ', and "', optional_value{3}, '"'];
          case 4
            optional_value_message = [', "', optional_value{1}, '"', ...
              ', "', optional_value{2}, '"', ...
              ', "', optional_value{3}, '"', ...
              ', and "', optional_value{4}, '"'];
          case 5
            optional_value_message = [', "', optional_value{1}, '"', ...
              ', "', optional_value{2}, '"', ...
              ', "', optional_value{3}, '"', ...
              ', "', optional_value{4}, '"', ...
              ', and "', optional_value{5}, '"'];
        end
    end
    allowed_values_message = ['The allowed values are ', ...
      default_value_message, ...
      optional_value_message, '.'];
  case 3
    default_value = varargin{1};
    optional_value_boundary = varargin{2};
    range_marker = varargin{3};
    switch range_marker
      case '<'
        allowed_values_message = ['The default value is ', ...
          num2str(default_value), ...
          ', and the allowed values must be smaller than ',...
          num2str(optional_value_boundary), '.'];
      case '<='
        allowed_values_message = ['The default value is ', ...
          num2str(default_value), ...
          ', and the allowed values must be smaller than or equal to ',...
          num2str(optional_value_boundary), '.'];
      case '>'
        allowed_values_message = ['The default value is ', ...
          num2str(default_value), ...
          ', and the allowed values must be larger than ',...
          num2str(optional_value_boundary), '.'];
      case '>='
        allowed_values_message = ['The default value is ', ...
          num2str(default_value), ...
          ', and the allowed values must be larger than or equal to ',...
          num2str(optional_value_boundary), '.'];
      case 'integer<'
        allowed_values_message = ['The default value is ', ...
          num2str(default_value), ...
          ', and the allowed values must be an integer, also smaller than ',...
          num2str(optional_value_boundary), '.'];
      case 'integer<='
        allowed_values_message = ['The default value is ', ...
          num2str(default_value), ...
          ', and the allowed values must be an integer, also smaller than or equal to ',...
          num2str(optional_value_boundary), '.'];
      case 'integer>'
        allowed_values_message = ['The default value is ', ...
          num2str(default_value), ...
          ', and the allowed values must be an integer, also larger than ',...
          num2str(optional_value_boundary), '.'];
      case 'integer>='
        allowed_values_message = ['The default value is ', ...
          num2str(default_value), ...
          ', and the allowed values must be an integer, also larger than or equal to ',...
          num2str(optional_value_boundary), '.'];
      otherwise
        warning('ID:invalid_input', 'optional_value_boundary must be double');
        return
    end
end
end

function options = fill_extract_segments(options)
% 2.21.1 set default ouput_nan
if ~isfield(options, 'nan_output')|| strcmpi(options.nan_output, 'none')
  options.nan_output = 'none';
elseif ~strcmpi( options.nan_output,'screen')
  [path, ~, ~ ]= fileparts(options.nan_output);
  if 7 ~= exist(path, 'dir')
    warning('ID:invalid_input', 'Path for nan_output does not exist');
    options.invalid = 1;
    return
  end
end
% 2.21.2 set default marker_chan, if it is a glm struct (only for non-raw data)
if options.manual_chosen == 1 || ...
    (options.manual_chosen == 0 && strcmpi(options.model_strc.modeltype,'glm'))
  if ~isfield(options, 'marker_chan')
    options.marker_chan = repmat({-1}, numel(options.data_fn),1);
  elseif ~iscell(options.marker_chan)
    options.marker_chan = repmat({options.marker_chan}, size(options.data_fn));
  end
end
% 2.21.3 check mutual arguments (options)
if strcmpi(options.timeunit, 'markers') && ...
    options.manual_chosen == 2 && ...
    ~isfield(options,'marker_chan')
  warning('ID:invalid_input',...
    '''markers'' specified as a timeunit but nothing was specified in ''options.marker_chan''');
  options.invalid = 1;
  return
elseif strcmpi(options.timeunit, 'markers') && ...
    options.manual_chosen == 2 && ...
    ~all(size(options.data_raw) == size(options.marker_chan))
  warning('ID:invalid_input',...
    '''data_raw'' and ''options.marker_chan'' do not have the same size.');
  options.invalid = 1;
  return
elseif strcmpi(options.timeunit, 'markers') && ...
    options.manual_chosen == 1 && ...
    ~all(size(options.data_fn) == size(options.marker_chan))
  warning('ID:invalid_input', ...
    '''data_fn'' and ''options.marker_chan'' do not have the same size.');
  options.invalid = 1;
  return
elseif options.manual_chosen == 1 || ...
    (options.manual_chosen == 0 && strcmpi(options.model_strc.modeltype,'glm'))
  if any(cellfun(@(x) ~strcmpi(x, 'marker') && ~isnumeric(x), options.marker_chan))
    warning('ID:invalid_input', ...
      'Options.marker_chan has to be numeric or ''marker''.');
    options.invalid = 1;
    return
  elseif strcmpi(options.timeunit, 'markers') ...
      && any(cellfun(@(x) isnumeric(x) && x <= 0, options.marker_chan))
    warning('ID:invalid_input', ...
      ['''markers'' specified as a timeunit but ', ...
      'no valid marker channel is defined.']);
    options.invalid = 1;
    return
  end
end
end

function options = fill_find_valid_fixations(options)
global settings
if isempty(settings)
  pspm_init;
end
if ~isfield(options, 'channels')
  options.channels = 'pupil';
elseif ~iscell(options.channels) && ~ischar(options.channels) && ...
    ~isnumeric(options.channels)
  warning('ID:invalid_input', ['Options.channels should be a char, ', ...
    'numeric or a cell of char or numeric.']);
  options.invalid = 1;
  return;
end
if ~iscell(options.channels)
  options.channels = {options.channels};
end
if strcmpi(options.mode,'fixation') && ~isfield(options, 'resolution')
  options.resolution = [1 1];
end
if strcmpi(options.mode,'fixation') && ~isfield(options, 'fixation_point')
  options.resolution = [0.5 0.5];
end
if iscell(options.channels) && any(~cellfun(@(x) isnumeric(x) || ...
    any(strcmpi(x, settings.findvalidfixations.channeltypes)), options.channels))
  warning('ID:invalid_input', 'Option.channels contains invalid values.');
  options.invalid = 1;
  return;
elseif strcmpi(options.mode,'fixation') && isfield(options, 'fixation_point') && ...
    (~isnumeric(options.fixation_point) || ...
    size(options.fixation_point,2) ~= 2)
  warning('ID:invalid_input', ['Options.fixation_point is not ', ...
    'numeric, or has the wrong size (should be nx2).']);
  options.invalid = 1;
  return;
elseif isfield(options, 'resolution') && (~isnumeric(options.resolution) || ...
    ~all(size(options.resolution) == [1 2]))
  warning('ID:invalid_input', ['Options.fixation_point is not ', ...
    'numeric, or has the wrong size (should be 1x2).']);
  options.invalid = 1;
  return;
elseif strcmpi(options.mode,'fixation') && isfield(options, 'fixation_point') &&  ...
    ~all(options.fixation_point < options.resolution)
  warning('ID:out_of_range', ['Some fixation points are larger than ', ...
    'the range given. Ensure fixation points are within the given ', ...
    'resolution.']);
  options.invalid = 1;
  return;
end
end

function options = fill_glm(options)
if ~isfield(options, 'marker_chan_num')
  options.marker_chan_num = 'marker';
elseif ~(isnumeric(options.marker_chan_num) && numel(options.marker_chan_num)==1)
  options.marker_chan_num = 'marker';
end
if isfield(options,'exclude_missing')
  if ~(isfield(options.exclude_missing, 'segment_length') && ...
      isfield(options.exclude_missing,'cutoff'))
    warning('ID:invalid_input', 'To extract the NaN-values segment-length and cutoff must be set');
    options.invalid = 1;
    return
  elseif ~(isnumeric(options.exclude_missing.segment_length) && isnumeric(options.exclude_missing.cutoff))
    warning('ID:invalid_input', 'To extract the NaN-values segment-length and cutoff must be numeric values.');
    options.invalid = 1;
    return
  end
end
end

function options = fill_find_sounds(options)
% options = autofill(options, 'roi', []);
if options.maxdelay < options.mindelay
  warning('ID:invalid_input', ...
    ['''options.mindelay'' and ''options.maxdelay'' ', ...
    'must be numeric and ''options.mindelay'' must be ', ...
    'smaller than ''options.maxdelay''']);
  options.invalid = 1;
end
if options.plot; options.diagnostics = true; end
try options.roi; catch, options.roi = []; end
if ~isempty(options.roi) && (length(options.roi) ~= 2 || ~all(isnumeric(options.roi) & options.roi >= 0))
  warning('ID:invalid_input', 'Option roi must be a float vector of length 2 or 0');
  options.invalid = 1;
end
end
