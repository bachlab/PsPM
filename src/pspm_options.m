function option_out = pspm_options(option_in, funcname)
% Definition
% pspm_options automatically determine the fields of options for the
% corresponding function
% option_in needs to be a struct
% Written by
% 2022 Teddy Chao (UCL)

option_out = option_in;
%% 1 Check field chan
if ~isfield(option_in, 'chan')
  switch funcname
    case 'blink_saccade_filt'
      option_out.chan = 0;
    case 'convert_ecg2hb_amri'
      option_out.chan = 'ecg';
    case 'convert_ppg2hb'
      option_out.chan = 'ppg2hb';
    case 'emg_pp'
      option_out.chan = 'emg';
  end
elseif ~isnumeric(options.chan) && ~ischar(options.chan)
  warning('ID:invalid_input', 'Option channel must be a string or numeric');
end
%% 2 check field chan_action
if ~isfield(option_in, 'chan_action')
  switch funcname
    case {'blink_saccade_filt', ...
        'compute_visual_angle', ...
        'convert_au2unit', ...
        'convert_gaze_distance', ...
        'convert_area2diameter', ...
        'convert_pixel2unit', ...
        'convert_visangle2sps', ...
        'find_valid_fixations', ...
        'interpolate'}
      option_out.chan_action = 'add';
    case {'convert_ecg2hb_amri', ...
        'convert_hb2hp', ...
        'convert_ppg2hb', ...
        'emg_pp'}
      option_out.chan_action = 'replace';
    case 'find_sound'
      option_out.chan_action = 'none';
  end
else
  if ~any(strcmpi(option_in.chan_action, ...
      {'add', 'replace', 'none'}))
    warning('ID:invalid_input', ...
      '''options.chan_action'' must be either ''add'', ''replace'', or ''none''.');
    return
  end
end