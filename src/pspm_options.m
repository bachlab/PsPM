function OptOut = pspm_options(OptIn, FuncName)
% Definition
% pspm_options automatically determine the fields of options for the
% corresponding function
% OptIn needs to be a struct
% Written by
% 2022 Teddy Chao (UCL)


%% 0 warning messages
StrOptChanInvalid = 'options.chan must contain valid channel types or positive integers.';
StrOptChanInvalid_char = 'options.chan is not a valid channel type.';


OptOut = [];

switch FuncName
  case 'convert_au2unit'
    OptOut = autofill_chan_action(OptIn);
  case 'convert_area2diameter'
    OptOut = autofill_chan_action(OptIn);
  case 'convert_pixel2unit'
    OptOut = autofill_chan_action(OptIn);
  case 'convert_visangle2sps'
    OptOut = autofill_chan_action(OptIn);
  case 'convert_hb2hp'
    OptOut = autofill_chan_action(OptIn, 'replace');
  case 'blink_saccade_filt'
    OptTemp = autofill(OptIn, 'chan', 0);
    OptOut = autofill_chan_action(OptTemp);
  case 'convert_gaze_distance'
    OptOut = autofill_chan_action(OptIn);
  case 'compute_visual_angle'
    OptOut = autofill_chan_action(OptIn);
  case 'convert_ecg2hb_amri'
   OptTemp = autofill(OptIn, 'chan', 'ecg');
   OptOut = autofill_chan_action(OptTemp, 'replace');
  case 'convert_ppg2hb'
    OptTemp = autofill(OptIn, 'chan', 'ppg2hb');
    OptOut = autofill_chan_action(OptTemp,  'replace');
  case 'emg_pp'
    OptTemp = autofill(OptIn, 'chan', 'emg');
   OptOut = autofill_chan_action(OptTemp, 'replace');
  case 'exp'
    OptTemp = autofill(OptIn, 'target', 'screen');
    OptTemp = autofill(OptTemp, 'statstype', 'param');
    OptTemp = autofill(OptTemp, 'delim', '\t');
    OptOut = autofill(OptTemp, 'exclude_missing', 0);
  case 'find_sound'
    OptOut = autofill_chan_action(OptIn, 'none', {'add','replace','none'});
  case 'find_valid_fixations'
    OptOut = autofill_chan_action(OptIn);
  case 'interpolate'
    OptOut = autofill_chan_action(OptIn);
  case 'write_channel'
    if ~isfield(OptIn, 'chan')
      warning('ID:invalid_input', StrOptChanInvalid);
      return
    else
      switch class(OptIn.chan)
        case 'char'
          if ~any(strcmpi(OptIn.chan,{'add','replace','none'}))
            warning('ID:invalid_input', StrOptChanInvalid_char);
            return
          else
            OptOut.chan = OptIn.chan;
          end
        case 'double'
          if (any(mod(OptIn.chan,1)) || any(OptIn.chan<0))
            warning('ID:invalid_input', StrOptChanInvalid);
            return;
          else
            OptOut.chan = OptIn.chan;
          end
        otherwise
          warning('ID:invalid_input', StrOptChanInvalid);
          return
      end
    end
end

function OptOut = autofill(OptIn, FieldName, DefaultValue)
OptOut = OptIn;
if ~isfield(OptIn, FieldName)
  OptOut.(FieldName) = DefaultValue;
else
  OptOut.(FieldName) = OptIn.(FieldName);
end

function OptOut = autofill_chan_action(varargin)
switch nargin
  case 1
    OptIn = varargin{1};
    DefaultValue = 'add';
    OptValue = {'add', 'replace'};
  case 2
    OptIn = varargin{1};
    DefaultValue = varargin{2};
    OptValue = {'add', 'replace'};
  case 3
    OptIn = varargin{1};
    DefaultValue = varargin{2};
    OptValue = varargin{3};
end
OptOut = OptIn;
if ~isfield(OptIn, 'chan_action')
  OptOut.chan_action = DefaultValue;
else
  if ~any(strcmpi(OptIn.chan_action, OptValue))
    warning('ID:invalid_input', ...
      '''options.chan_action'' must be among accepted values.');
    return
  end
  OptOut.chan_action = OptIn.chan_action;
end