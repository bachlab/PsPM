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

%% 1 Text
text_optional_channel_invalid = 'options.channel must contain valid channel types or positive integers.';
text_optional_channel_invalid_char = 'options.channel is not a valid channel type.';

%% 2 Main Processing
switch FunName
  case 'blink_saccade_filt'
    options = autofill(options, 'channel', 0);
    options = autofill_channel_action(options);
  case 'compute_visual_angle_core'
    options = autofill(options,'interpolate',0,1);
  case 'compute_visual_angle'
    options = autofill(options,'eyes',settings.lateral.char.b,{settings.lateral.char.l,settings.lateral.char.r});
    options = autofill_channel_action(options);
  case 'con1'
    options = autofill(options,'zscored',0,1);
  case 'con2'
    options = autofill_channel_action(options);
  case 'convert_area2diameter'
    options = autofill_channel_action(options);
  case 'convert_au2unit'
    options = autofill_channel_action(options);
  case 'convert_ecg2hb'
    options = autofill_channel_action(options, 'replace');
    options = autofill(options, 'debugmode', 0, 1); % can be merged into development mode?
    options = autofill(options, 'semi', 0, 1); % semi==1 will pop a dialog
    options = autofill(options, 'maxHR', 200, '>', 20); % field: maxHR (bpm)
    options = autofill(options, 'minHR', 20, '<', 200); % field: minHR (bpm)
    options = autofill(options, 'twthresh', 0.36);
    options = autofill(options, 'outfact', 2);
    if options.maxHR < options.minHR
      warning('ID:invalid_input', ...
        ['''options.minHR'' and ''options.maxHR'' ', ...
        'must be numeric and ''options.minHR'' must be ', ...
        'smaller than ''options.maxHR''']);
      return
    end
  case 'convert_ecg2hb_amri'
    options = autofill(options, 'channel', 'ecg');
    options = autofill(options, 'signal_to_use', 'auto', {'ecg', 'teo'});
    options = autofill(options, 'hrrange', [20 200], '>', 0);
    options = autofill(options, 'ecg_bandpass', [0.5 40], '>', 0);
    options = autofill(options, 'teo_bandpass', [8 40], '>', 0);
    options = autofill(options, 'teo_order', 1, '>', 0);
    options = autofill(options, 'min_cross_corr', 0.5);
    options = autofill(options, 'min_relative_amplitude', 0.4);
    options = autofill_channel_action(options);
  case 'convert_gaze_distance'
    options = autofill_channel_action(options);
  case 'convert_hb2hp'
    options = autofill_channel_action(options, 'replace');
    options = autofill(options, 'limit.lower', 0.2);
    options = autofill(options, 'limit.upper', 2);
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
    options = autofill_channel_action(options, 'none', {'add','replace'});
  case 'find_valid_fixations'
    options = autofill_channel_action(options);
  case 'gaze_pp'
    options = autofill(options, 'channel', 'gaze_x_l');
    options = autofill_channel_action(options, 'add', {'replace','none'});
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
    options = autofill(options, 'zscored', 0, 1);
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
      if ~flag_is_allowed_value
        allowed_values_message = generate_allowed_values_message(default_value);
        warning('ID:invalid_input', ['options.', field_name, ' is invalid. ',...
          allowed_values_message]);
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
      switch class(optional_value)
        case 'double'
          if length(default_value) ~= length(options.(field_name))
            flag_is_allowed_value = 0;
          else
            allowed_value = [optional_value; default_value];
            truetable = options.(field_name) == allowed_value;
            flag_is_allowed_value = any(sum(truetable,2));
          end
        case 'char'
          allowed_value = {optional_value, default_value};
          flag_is_allowed_value = strcmp(options.(field_name), allowed_value);
        case 'cell'
          allowed_value = {optional_value, default_value};
          flag_is_allowed_value = isequal(options.(field_name), allowed_value);
      end
      if ~flag_is_allowed_value
        allowed_values_message = generate_allowed_values_message(default_value, optional_value);
        warning('ID:invalid_input', ['options.', field_name, ' is invalid. ',...
          allowed_values_message]);
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
      switch class(optional_value_boundary)
        case 'double'
          if length(default_value) ~= length(options.(field_name))
            flag_is_allowed_value = 0;
          else
            switch range_marker
              case '>'
                flag_is_allowed_value = options.(field_name) > optional_value_boundary;
              case '>='
                flag_is_allowed_value = options.(field_name) >= optional_value_boundary;
              case '<'
                flag_is_allowed_value = options.(field_name) < optional_value_boundary;
              case '<='
                flag_is_allowed_value = options.(field_name) <= optional_value_boundary;
              otherwise
                warning('ID:invalid_input', 'range_marker must be <, >, <=, or >=.');
            end
          end
        otherwise
          warning('ID:invalid_input', 'optional_value_boundary must be a double value for using ranges.');
      end
      if ~flag_is_allowed_value
        allowed_values_message = generate_allowed_values_message(default_value, optional_value_boundary, range_marker);
        warning('ID:invalid_input', ['options.', field_name, ' is invalid. ',...
          allowed_values_message]);
        return
      end
    end
  otherwise
    warning('ID:invalid_input', 'autofill needs at least 3 arguments');
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
      ['''options.channel_action'' must be among accepted values. '...
      allowed_values_message]);
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
      case '>'
        allowed_values_message = ['The default value is ', ...
          num2str(default_value), ...
          ', and the allowed values must be larger than ',...
          num2str(optional_value_boundary), '.'];
      otherwise
        warning('ID:invalid_input', 'optional_value_boundary must be double');
    end
end
end