function Opt = pspm_options(Opt, FuncName)
% Definition
% pspm_options automatically determine the fields of options for the
% corresponding function
% Opt needs to be a struct
% Written by
% 2022 Teddy Chao (UCL)

StrOptChanInvalid = 'options.chan must contain valid channel types or positive integers.';
StrOptChanInvalid_char = 'options.chan is not a valid channel type.';
switch FuncName
  case 'blink_saccade_filt'
    Opt = Autofill(Opt,'chan', 0);
    Opt = AutofillChanAction(Opt);
  case 'compute_visual_angle'
    Opt = AutofillChanAction(Opt);
  case 'convert_area2diameter'
    Opt = AutofillChanAction(Opt);
  case 'convert_au2unit'
    Opt = AutofillChanAction(Opt);
  case 'convert_ecg2hb_amri'
    Opt = Autofill(Opt, 'chan', 'ecg');
    Opt = AutofillChanAction(Opt, 'replace');
  case 'convert_gaze_distance'
    Opt = AutofillChanAction(Opt);
  case 'convert_hb2hp'
    Opt = AutofillChanAction(Opt, 'replace');
  case 'convert_pixel2unit'
    Opt = AutofillChanAction(Opt);
  case 'convert_ppg2hb'
    Opt = Autofill(Opt,'chan', 'ppg2hb');
    Opt = AutofillChanAction(Opt, 'replace');
  case 'convert_visangle2sps'
    Opt = AutofillChanAction(Opt);
  case 'emg_pp'
    Opt = Autofill(Opt,'chan', 'emg');
    Opt = AutofillChanAction(Opt, 'replace');
  case 'exp'
    Opt = Autofill(Opt,'target', 'screen');
    Opt = Autofill(Opt, 'statstype', 'param');
    Opt = Autofill(Opt, 'delim', '\t');
    Opt = Autofill(Opt, 'exclude_missing', 0);
  case 'find_sound'
    Opt = AutofillChanAction(Opt, 'none', {'add','replace','none'});
  case 'find_valid_fixations'
    Opt = AutofillChanAction(Opt);
  case 'interpolate'
    Opt = AutofillChanAction(Opt);
  case 'sf'
    Opt = Autofill(Opt,'overwrite', 0);
    if ~isfield(Opt,'marker_chan_num') ||...
        ~isnumeric(Opt.marker_chan_num) ||...
        numel(Opt.marker_chan_num) > 1
      Opt.marker_chan_num = 0;
    end
  case 'write_channel'
    if ~isfield(Opt, 'chan')
      warning('ID:invalid_input', StrOptChanInvalid);
      return
    else
      switch class(Opt.chan)
        case 'char'
          if ~any(strcmpi(Opt.chan,{'add','replace','none'}))
            warning('ID:invalid_input', StrOptChanInvalid_char);
            return
          end
        case 'double'
          if (any(mod(Opt.chan,1)) || any(Opt.chan<0))
            warning('ID:invalid_input', StrOptChanInvalid);
            return
          end
        otherwise
          warning('ID:invalid_input', StrOptChanInvalid);
          return
      end
    end
end
function Opt = Autofill(Opt, FieldName, DefaultValue)
if ~isfield(Opt, FieldName)
  Opt.(FieldName) = DefaultValue;
else
  Opt.(FieldName) = Opt.(FieldName);
end
function Opt = AutofillChanAction(Opt, varargin)
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
if ~isfield(Opt, 'chan_action')
  Opt.chan_action = DefaultValue;
else
  if ~any(strcmpi(Opt.chan_action, OptValue))
    warning('ID:invalid_input', ...
      '''options.chan_action'' must be among accepted values.');
    return
  end
end