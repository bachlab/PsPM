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

StrOptChanInvalid = 'options.channel must contain valid channel types or positive integers.';
StrOptChanInvalidChar = 'options.channel is not a valid channel type.';
switch FunName
  case 'blink_saccade_filt'
    options = Autofill(options,'channel', 0);
    options = AutofillChanAction(options);
  case 'compute_visual_angle_core'
    options = Autofill(options,'interpolate',0);
  case 'compute_visual_angle'
    options = AutofillChanAction(options);
  case 'con1'
    options = AutofillChanAction(options,'zscored',0);
  case 'convert_area2diameter'
    options = AutofillChanAction(options);
  case 'convert_au2unit'
    options = AutofillChanAction(options);
  case 'convert_ecg2hb_amri'
    options = Autofill(options, 'channel', 'ecg');
    options = AutofillChanAction(options, 'replace');
  case 'convert_gaze_distance'
    options = AutofillChanAction(options);
  case 'convert_hb2hp'
    options = AutofillChanAction(options, 'replace');
  case 'convert_pixel2unit'
    options = AutofillChanAction(options);
  case 'convert_ppg2hb'
    options = Autofill(options, 'channel', 'ppg2hb');
    options = AutofillChanAction(options, 'replace');
  case 'convert_visangle2sps'
    options = AutofillChanAction(options);
  case 'emg_pp'
    options = Autofill(options, 'channel', 'emg');
    options = AutofillChanAction(options, 'replace');
  case 'exp'
    options = Autofill(options, 'target', 'screen');
    options = Autofill(options, 'statstype', 'param');
    options = Autofill(options, 'delim', '\t');
    options = Autofill(options, 'exclude_missing', 0);
  case 'find_sound'
    options = AutofillChanAction(options, 'none', {'add','replace','none'});
  case 'find_valid_fixations'
    options = AutofillChanAction(options);
  case 'gaze_pp'
    options = Autofill(options, 'channel', 'gaze_x_l');
    options = AutofillChanAction(options, 'add', {'add','replace','none'});
    options = Autofill(options, 'channel_combine', 'none');
    options = Autofill(options, 'segments', {});
    options = Autofill(options, 'valid_sample', 0);
    options = Autofill(options, 'plot_data', false);
  case 'glm'
    options = Autofill(options, 'modelspec', 'scr');
    options = Autofill(options, 'bf', 0);
    options = Autofill(options, 'overwrite', 0, 1);
    options = Autofill(options, 'norm', 0);
    options = Autofill(options, 'centering', 1);
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
  case 'import'
    options = Autofill(options, 'overwrite', 0, 1);
  case 'interpolate'
    options = AutofillChanAction(options);
  case 'sf'
    options = Autofill(options,'overwrite', 0);
    if ~isfield(options,'marker_chan_num') ||...
        ~isnumeric(options.marker_chan_num) ||...
        numel(options.marker_chan_num) > 1
      options.marker_chan_num = 0;
    end
  case 'split_sessions'
    options = Autofill(options, 'overwrite', 0, 1);
    options = Autofill(options, 'prefix', 0);
    options = Autofill(options, 'suffix', 0);
    options = Autofill(options, 'verbose', 0);
    options = Autofill(options, 'splitpoints', []);
    options = Autofill(options, 'missing', 0);
    options = Autofill(options, 'randomITI', 0);
    options = Autofill(options, 'max_sn', settings.split.max_sn);
    % maximum number of sessions (default 10)
    options = Autofill(options, 'max_sn', settings.split.min_break_ratio);
    % minimum ratio of session break to normal inter marker interval (default 3)
  case 'trim'
    options = Autofill(options, 'overwrite', 0, 1);
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
      warning('ID:invalid_input', StrOptChanInvalid);
      return
    else
      switch class(options.channel)
        case 'char'
          if ~any(strcmpi(options.channel,{'add','replace','none'}))
            warning('ID:invalid_input', StrOptChanInvalidChar);
            return
          end
        case 'double'
          if (any(mod(options.channel, 1)) || any(options.channel<0))
            warning('ID:invalid_input', StrOptChanInvalid);
            return
          end
        otherwise
          warning('ID:invalid_input', StrOptChanInvalid);
          return
      end
    end
end

function options = Autofill(varagin)
switch nargin
  case 3
    options = varagin{1};
    FieldName = varagin{2};
    DefaultValue = varagin{3};
    if ~isfield(options, FieldName)
      options.(FieldName) = DefaultValue;
    end
  case 4
    options = varagin{1};
    FieldName = varagin{2};
    DefaultValue = varagin{3};
    AcceptableValue = varagin{4};
    if ~isfield(options, FieldName)
      options.(FieldName) = DefaultValue;
    else
      if options.(FieldName) ~= AcceptableValue
        options.(FieldName) = DefaultValue;
      end
    end
  otherwise
    warning('ID:invalid_input', 'Autofill needs at least 3 arguments');
    return
  end
end

function options = AutofillChanAction(options, varargin)
switch nargin
  case 1
    DefaultValue = 'add';
    OptValue = {'add', 'replace'};
  case 2
    DefaultValue = varargin{1};
    OptValue = {'add', 'replace'};
  case 3
    DefaultValue = varargin{1};
    OptValue = varargin{2};    
end
if ~isfield(options, 'channel_action')
  options.channel_action = DefaultValue;
else
  if ~any(strcmpi(options.channel_action, OptValue))
    warning('ID:invalid_input', ...
      '''options.channel_action'' must be among accepted values.');
    return
  end
end