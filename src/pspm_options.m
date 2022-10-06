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

global settings
if isempty(settings)
  pspm_init;
end
text_optional_channel_invalid = 'options.channel must contain valid channel types or positive integers.';
text_optional_channel_invalid_char = 'options.channel is not a valid channel type.';
switch FunName
  case 'blink_saccade_filt'
    options = autofill(options, 'channel', 0);
    options = autofill_channel_action(options);
  case 'compute_visual_angle_core'
    options = autofill(options,'interpolate',0);
  case 'compute_visual_angle'
    options = autofill_channel_action(options);
  case 'con1'
    options = autofill_channel_action(options,'zscored',0);
  case 'convert_area2diameter'
    options = autofill_channel_action(options);
  case 'convert_au2unit'
    options = autofill_channel_action(options);
  case 'convert_ecg2hb_amri'
    options = autofill(options, 'channel', 'ecg');
    options = autofill_channel_action(options, 'replace');
  case 'convert_gaze_distance'
    options = autofill_channel_action(options);
  case 'convert_hb2hp'
    options = autofill_channel_action(options, 'replace');
  case 'convert_pixel2unit'
    options = autofill_channel_action(options);
  case 'convert_ppg2hb'
    options = autofill(options, 'channel', 'ppg2hb');
    options = autofill_channel_action(options, 'replace');
  case 'convert_visangle2sps'
    options = autofill_channel_action(options);
  case 'emg_pp'
    options = autofill(options, 'channel', 'emg');
    options = autofill_channel_action(options, 'replace');
  case 'exp'
    options = autofill(options, 'target', 'screen');
    options = autofill(options, 'statstype', 'param');
    options = autofill(options, 'delim', '\t');
    options = autofill(options, 'exclude_missing', 0);
  case 'find_sound'
    options = autofill_channel_action(options, 'none', {'add','replace','none'});
  case 'find_valid_fixations'
    options = autofill_channel_action(options);
  case 'gaze_pp'
    options = autofill(options, 'channel', 'gaze_x_l');
    options = autofill_channel_action(options, 'add', {'add','replace','none'});
    options = autofill(options, 'channel_combine', 'none');
    options = autofill(options, 'segments', {});
    options = autofill(options, 'valid_sample', 0);
    options = autofill(options, 'plot_data', false);
  case 'glm'
    options = autofill(options, 'modelspec', 'scr');
    options = autofill(options, 'bf', 0);
    options = autofill(options, 'overwrite', 0, 1);
    options = autofill(options, 'norm', 0);
    options = autofill(options, 'centering', 1);
    if ~isfield(options, 'marker_chan_num')
      options.marker_chan_num = 'marker';
    elseif ~(isnumeric(options.marker_chan_num) && numel(options.marker_chan_num)==1)
      options.marker_chan_num = 'marker';
    end
    if isfield(options,'exclude_missing')
      if ~(isfield(options.exclude_missing, 'segment_length') && ...
  				isfield(options.exclude_missing,'cutoff'))
        warning('ID:invalid_input', 'To extract the NaN-values segment-length and cutoff must be set');
        return
      elseif ~(isnumeric(options.exclude_missing.segment_length) && isnumeric(options.exclude_missing.cutoff))
        warning('ID:invalid_input', 'To extract the NaN-values segment-length and cutoff must be numeric values.');
        return
      end
    end
  case 'load1'
    options = autofill(options, 'overwrite', 0, 1);
    options = autofill(options, 'zscored', 0);
  case 'import'
    % options = autofill(options, 'overwrite', 0, 1);
  case 'interpolate'
    options = autofill_channel_action(options);
    try options.overwrite; catch, options.overwrite = 0; end
  case 'sf'
    options = autofill(options,'overwrite', 0);
    if ~isfield(options,'marker_chan_num') ||...
  			~isnumeric(options.marker_chan_num) ||...
  			numel(options.marker_chan_num) > 1
      options.marker_chan_num = 0;
    end
  case 'split_sessions'
    options = autofill(options, 'overwrite', 0, 1);
    options = autofill(options, 'prefix', 0);
    options = autofill(options, 'suffix', 0);
    options = autofill(options, 'verbose', 0);
    options = autofill(options, 'splitpoints', []);
    options = autofill(options, 'missing', 0);
    options = autofill(options, 'randomITI', 0);
    options = autofill(options, 'max_sn', settings.split.max_sn);
    % maximum number of sessions (default 10)
    options = autofill(options, 'min_break_ratio', settings.split.min_break_ratio);
    % minimum ratio of session break to normal inter marker interval (default 3)
  case 'trim'
    options = autofill(options, 'overwrite', 0, 1);
    if ~isfield(options,'marker_chan_num') || ...
  			~isnumeric(options.marker_chan_num) || ...
  			numel(options.marker_chan_num) > 1
      options.marker_chan_num = 0;
    end
    if ~isfield(options, 'drop_offset_markers') || ...
  			~isnumeric(options.drop_offset_markers)
      options.drop_offset_markers = 0;
    end
  case 'write_channel'
    if ~isfield(options, 'channel')
      warning('ID:invalid_input', text_optional_channel_invalid);
      return
    else
      switch class(options.channel)
  			case 'char'
  				if ~any(strcmpi(options.channel,{'add','replace','none'}))
  					warning('ID:invalid_input', text_optional_channel_invalid_char);
  					return
  				end
  			case 'double'
  				if (any(mod(options.channel, 1)) || any(options.channel<0))
  					warning('ID:invalid_input', text_optional_channel_invalid);
  					return
  				end
  			otherwise
  				warning('ID:invalid_input', text_optional_channel_invalid);
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
    end
  case 4
    options = varargin{1};
    field_name = varargin{2};
    default_value = varargin{3};
    acceptable_value = varargin{4};
    if ~isfield(options, field_name)
      options.(field_name) = default_value;
    else
      if options.(field_name) ~= acceptable_value && options.(field_name) ~= default_value
        options.(field_name) = default_value;
      end
    end
  otherwise
    warning('ID:invalid_input', 'autofill needs at least 3 arguments');
    return
end
end

function options = autofill_channel_action(options, varargin)
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
  if ~any(strcmpi(options.channel_action, optional_value))
    warning('ID:invalid_input', ...
      '''options.channel_action'' must be among accepted values.');
    return
  end
end
end