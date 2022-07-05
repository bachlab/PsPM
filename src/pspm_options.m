function options_out = pspm_options(options_in, funcname)
% Definition
% pspm_options automatically determine the fields of options for the
% corresponding function
% options_in needs to be a struct
% Written by
% 2022 Teddy Chao (UCL)


%% 0 warning messages
str_options_chan_invalid = 'options.chan must contain valid channel types or positive integers.';
str_options_chan_invalid_char = 'options.chan is not a valid channel type.';


options_out = [];

switch funcname
  case 'convert_au2unit'
    options_out = autofill_chan_action(options_in,  'add', {'add', 'replace'});
  case 'convert_area2diameter'
    options_out = autofill_chan_action(options_in,  'add', {'add', 'replace'});
  case 'convert_pixel2unit'
    options_out = autofill_chan_action(options_in,  'add', {'add', 'replace'});
  case 'convert_visangle2sps'
    options_out = autofill_chan_action(options_in,  'add', {'add', 'replace'});
  case 'convert_hb2hp'
    options_out = autofill_chan_action(options_in,  'replace', {'add', 'replace'});
  case 'blink_saccade_filt'
    options_temp = autofill(options_in, 'chan', 0);
    options_out = autofill_chan_action(options_temp,  'add', {'add', 'replace'});
  case 'convert_gaze_distance'
    options_out = autofill_chan_action(options_in,  'add', {'add', 'replace'});
  case 'compute_visual_angle'
    options_out = autofill_chan_action(options_in,  'add', {'add', 'replace'});
  % case 'convert_ecg2hb_amri'
  %  options_temp = autofill(options_in, 'chan', 'ecg');
  %  options_out = autofill_chan_action(options_temp,  'replace', {'add', 'replace'});
  case 'convert_ppg2hb'
    options_temp = autofill(options_in, 'chan', 'ppg2hb');
    options_out = autofill_chan_action(options_temp,  'replace', {'add', 'replace'});
  case 'emg_pp'
    options_temp = autofill(options_in, 'chan', 'emg');
   options_out = autofill_chan_action(options_temp, 'replace', {'add', 'replace'});
  case 'exp'
    options_temp = autofill(options_in, 'target', 'screen');
    options_temp = autofill(options_temp, 'statstype', 'param');
    options_temp = autofill(options_temp, 'delim', '\t');
    options_out = autofill(options_temp, 'exclude_missing', 0);
  case 'find_sound'
    options_out = autofill_chan_action(options_in,  'none', {'add', 'replace', 'none'});
  case 'find_valid_fixations'
    options_out = autofill_chan_action(options_in,  'add', {'add', 'replace'});
  case 'interpolate'
    options_out = autofill_chan_action(options_in,  'add', {'add', 'replace'});
  case 'write_channel'
    if ~isfield(options_in, 'chan')
      warning('ID:invalid_input', str_options_chan_invalid);
      return
    else
      switch class(options_in.chan)
        case 'char'
          if ~any(strcmpi(options_in.chan,{'add','replace','none'}))
            warning('ID:invalid_input', str_options_chan_invalid_char);
            return
          else
            options_out.chan = options_in.chan;
          end
        case 'double'
          if (any(mod(options_in.chan,1)) || any(options_in.chan<0))
            warning('ID:invalid_input', str_options_chan_invalid);
            return;
          else
            options_out.chan = options_in.chan;
          end
        otherwise
          warning('ID:invalid_input', str_options_chan_invalid);
          return
      end
    end
end

function options_out = autofill(options_in, fieldname, defaultvalue)
options_out = options_in;
if ~isfield(options_in, fieldname)
  options_out.(fieldname) = defaultvalue;
else
  options_out.(fieldname) = options_in.(filedname);
end

function options_out = autofill_chan_action(options_in, defaultvalue, optionvalue)
options_out = options_in;
if ~isfield(options_in, 'chan_action')
  options_out.chan_action = defaultvalue;
else
  if ~any(strcmpi(options_in.chan_action, ...
      optionvalue))
    warning('ID:invalid_input', ...
      '''options.chan_action'' must be among accepted values.');
    return
  end
  options_out.chan_action = options_in.chan_action;
end