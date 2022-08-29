function [sts, out_channel] = pspm_pupil_correct_eyelink(fn, options)
% ● Description
%   pspm_pupil_correct_eyelink performs pupil foreshortening error (PFE)
%   correction specifically for Eyelink recorded and imported data following
%   the steps described in [1]. For details of the exact scaling, see
%   <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>.
% ● Developer's Notes
%   In order to perform PFE, we need both pupil and gaze data. If the gaze data
%   in the given file is in pixels, we need information about the screen
%   dimensions and resolution to calculate the pixel to milimeter ratio. On the
%   other hand, if the gaze data is in mm, cm, inches, etc., there is no need
%   to enter any screen size related information. If the gaze data is in pixels
%   and screen information is not given, the function emits a warning and exits
%   early. Once the pupil data is preprocessed, according to the option
%   'channel_action', it will either replace an existing preprocessed pupil
%   channel or add it as new channel to the provided file.
% ● Format
%   [sts, out_channel] = pspm_pupil_correct_eyelink(fn, options)
% ● Arguments
%              fn:  Path to a PsPM imported Eyelink data.
%   ┌─────options:
%   │ ▶︎ mandatory
%   ├────────mode:  Conversion mode. Must be one of 'auto' or 'manual'.
%   │               If 'auto', then optimized conversion parameters in
%   │               Table 3 of [1] will be used. In 'auto' mode,
%   │               options struct must contain C_z parameter described
%   │               below. Further, C_z must be one of 495, 525 or 625.
%   │               The other parameters will be set according to which
%   │               of these three C_z is equal to.
%   │               If 'manual', then all of C_x, C_y, C_z, S_x, S_y, S_z
%   │               fields must be provided according to your recording
%   │               setup. Note that in order to use 'auto' mode, your
%   │               camera-screen-eye setup must match exactly one of the three
%   │               sample setups given in [1].
%   ├─────────C_z:  See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
%   │ ▶︎ optional
%   ├screen_size_px:Screen size (width x height). This field is required only
%   │               if the gaze data in the given PsPM file is in pixels.
%   │               (Unit: pixel)
%   ├screen_size_mm:Screen size (width x height). This field is required only
%   │               if the gaze data in the given PsPM file is in pixels.
%   │               (Unit: mm)
%   │               See <a href="matlab:help pspm_convert_unit">pspm_convert_unit</a>
%   │               if you need inch to mm conversion.
%   ├─────────C_x:  See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
%   ├─────────C_y:  See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
%   ├─────────S_x:  See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
%   ├─────────S_y:  See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
%   ├─────────S_z:  See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
%   ├─────channel:  [numeric/string] Channel ID to be preprocessed.
%   │               (Default: 'pupil')
%   │               * Preprocessing raw eye data:
%   │                 The best eye is processed when channel is 'pupil'.
%   │                 In order to process a specific eye, use 'pupil_l' or
%   │                 'pupil_r'.
%   │               * Preprocessing previously processed data:
%   │                 Pupil channels created from other preprocessing steps
%   │                 can be further processed by this function. To enable
%   │                 this, pass one of 'pupil_pp_l' or 'pupil_pp_r'. There
%   │                 is no best eye selection in this mode. Hence, the
%   │                 type of the channel must be given exactly.
%   │               * Finally, a channel can be specified by its
%   │                 index in the given PsPM data structure. It will be
%   │                 preprocessed as long as it is a valid pupil channel.
%   │               * If channel is specified as a string and there are
%   │                 multiple channels with the exact same type, only the
%   │                 last one will be processed. This is normally not the
%   │                 case with raw data channels; however, there may be
%   │                 multiple preprocessed channels with same type if 'add'
%   │                 channel_action was previously used. This feature can
%   │                 be combined with 'add' channel_action to create
%   │                 preprocessing histories where the result of each step
%   │                 is stored as a separate channel.
%   │               * In all of the above cases, if the type of the input
%   │                 channel does not contain a '_pp' suffix, then a '_pp'
%   │                 suffix will be appended to the type of the output channel.
%   │                 Therefore, this function should not overwrite a raw data
%   │                 channel.
%   └channel_action:  ['add'/'replace'] Defines whether output data should
%                     be added or the corresponding preprocessed channel
%                     should be replaced. Note that 'replace' mode does not
%                     replace raw data channels. It replaces a previously
%                     stored preprocessed channel with a '_pp' suffix at the
%                     end of its type.
%                     (Default: 'add')
% ● Outputs
%       out_channel:  Channel index of the stored output channel.
% ● Reference
%   [1] Hayes, Taylor R., and Alexander A. Petrov. "Mapping and correcting the
%       influence of gaze position on pupil size measurements." Behavior
%       Research Methods 48.2 (2016): 510-527.
% ● Copyright
%   Introduced in PsPM 5.1.2
%   Written in 2019 by Eshref Yozdemir (University of Zurich)
%   Maintained in 2021-2022 by Teddy Chao (UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

%% Default values

all_fieldnames = {'C_x', 'C_y', 'C_z', 'S_x', 'S_y', 'S_z'};
default_params = containers.Map('KeyType', 'double', 'ValueType', 'any');
default_params(495) = [103, -215, 495, -142, 206, 736];
default_params(525) = [165, -239, 525, -87, 140, 851];
default_params(625) = [183, -230, 625, -76, 156, 937];

%% input checks

if ~ischar(fn)
  warning('ID:invalid_input', 'Data file must be a char.');
  return;
end
if ~isfield(options, 'mode')
  warning('ID:invalid_input', 'options struct must contain ''mode''');
  return;
end
if ~any(strcmpi(options.mode, {'auto', 'manual'}))
  warning('ID:invalid_input', 'options.mode must be ''auto'' or ''manual''');
  return;
end
if ~isfield(options, 'C_z')
  warning('ID:invalid_input', 'options struct must contain ''C_z''');
  return;
end
if ~isnumeric(options.C_z)
  warning('ID:invalid_input', 'options.C_z must be numeric');
  return;
end
if strcmp(options.mode, 'manual')
  for field = all_fieldnames
    if ~isfield(options, field{1})
      warning('ID:invalid_input',...
        'In manual mode, options must contain all geometry parameters');
      return;
    end
  end
end

%% create default arguments

if isfield(options, 'channel_action')
  if ~any(strcmpi(options.channel_action, {'add', 'replace'}))
    warning('ID:invalid_input',...
      'options.channel_action must be ''add'' or ''replace''');
    return;
  end
else
  options.channel_action = 'add';
end

if ~isfield(options, 'channel')
  options.chan = 'pupil';
end

if strcmpi(options.mode, 'auto')
  if ismember(options.C_z, cell2mat(keys(default_params)))
    for i = 1:numel(all_fieldnames)
      name_i = all_fieldnames{i};
      values = default_params(options.C_z);
      options.(name_i) = values(i);
    end
  else
    warning('ID:invalid_input',...
      'options.C_z must be one of 495, 525 or 625 in auto mode');
    return;
  end
end

%% load data

[lsts, ~, pupil_data] = pspm_load_data(fn, options.chan);
if lsts ~= 1
  return
end
if numel(pupil_data) > 1
  warning('ID:multiple_chans', ['There is more than one channel'...
    ' with type %s in the data file.\n'...
    ' We will process only the last one.\n'], options.chan);
  pupil_data = pupil_data(end);
end
old_chantype = pupil_data{1}.header.chantype;
if ~contains(old_chantype, 'pupil')
  warning('ID:invalid_input', 'Specified channel is not a pupil channel');
  return;
end

is_left = contains(old_chantype, '_l');
is_both = contains(old_chantype, '_c');
if is_both
  warning('ID:invalid_input',...
    'pspm_pupil_correct_eyelink cannot work with combined pupil channels');
  return;
end
if is_left
  gaze_x_chan = 'gaze_x_l';
  gaze_y_chan = 'gaze_y_l';
else
  gaze_x_chan = 'gaze_x_r';
  gaze_y_chan = 'gaze_y_r';
end

[lsts, ~, gaze_x_data] = pspm_load_data(fn, gaze_x_chan);
if lsts ~= 1; return; end
[lsts, ~, gaze_y_data] = pspm_load_data(fn, gaze_y_chan);
if lsts ~= 1; return; end

if numel(gaze_x_data) > 1
  warning('ID:multiple_chans',...
    'There are more than one gaze x channel. We will use the last one');
  gaze_x_data = gaze_x_data(end:end);
end
if numel(gaze_y_data) > 1
  warning('ID:multiple_chans',...
    'There are more than one gaze y channel. We will use the last one');
  gaze_y_data = gaze_y_data(end:end);
end

%% conditionally mandatory input checks

if strcmp(gaze_x_data{1}.header.units, 'pixel') || strcmp(gaze_y_data{1}.header.units, 'pixel')
  if ~isfield(options, 'screen_size_px')
    warning('ID:invalid_input', 'options struct must contain ''screen_size_px''');
    return;
  end
  if ~isfield(options, 'screen_size_mm')
    warning('ID:invalid_input', 'options struct must contain ''screen_size_mm''');
    return;
  end
  if ~isnumeric(options.screen_size_px) ||...
      ~all(size(options.screen_size_px) == [1 2]) ||...
      any(options.screen_size_px <= 0)
    warning('ID:invalid_input',...
      'options.screen_size_px must be a numeric array of size [1 2]');
    return;
  end
  if ~isnumeric(options.screen_size_mm) ||...
      ~all(size(options.screen_size_mm) == [1 2]) ||...
      any(options.screen_size_mm <= 0)
    warning('ID:invalid_input',...
      'options.screen_size_mm must be a numeric array of size [1 2]');
    return;
  end
else
  options.screen_size_mm = [NaN NaN];
  options.screen_size_px = [NaN NaN];
end

%% gaze conversion

gaze_x_mm = get_gaze_in_mm(gaze_x_data{1}.data,...
  gaze_x_data{1}.header.units, options.screen_size_mm(1),...
  options.screen_size_px(1));
gaze_y_mm = get_gaze_in_mm(gaze_y_data{1}.data,...
  gaze_y_data{1}.header.units, options.screen_size_mm(2),...
  options.screen_size_px(2));
pupil = pupil_data{1}.data;

%% correction
[sts, pupil_corrected] = pspm_pupil_correct(pupil, gaze_x_mm, gaze_y_mm, options);
if sts ~= 1; return; end

%% save data
pupil_data{1}.data = pupil_corrected;
pupil_data{1}.header.chantype = convert_pp(old_chantype);
channel_str = num2str(options.chan);
o.msg.prefix = sprintf(...
  'PFE correction :: Input channel: %s -- Input chantype: %s -- Output chantype: %s --', ...
  channel_str, ...
  old_chantype, ...
  pupil_data{1}.header.chantype);
[lsts, out_id] = pspm_write_channel(fn, pupil_data, options.channel_action, o);
if lsts ~= 1; return; end

out_channel = out_id.chan;
sts = 1;
end

function gaze_mm = get_gaze_in_mm(gaze_data, units, side_mm, side_px)
if strcmp(units, 'pixel')
  gaze_mm = gaze_data * (side_mm / side_px);
else
  [~, gaze_mm] = pspm_convert_unit(gaze_data, units, 'mm');
end
end

function chantype_pp = convert_pp(chantype)
global settings;
if isempty(settings), pspm_init; end
% analyse channel type and convert it as preprocessed (pp) channel type
chantype_array = split(chantype,'_');
% find if there is pp
is_pp = any(strcmp(chantype_array,'pp'));
% find if it is combined (c), left (l) or right (r)
is_c = any(strcmp(chantype_array, settings.lateral.char.c));
is_l = any(strcmp(chantype_array, settings.lateral.char.l));
is_r = any(strcmp(chantype_array, settings.lateral.char.r));
if ~is_pp
  if is_c
    chantype_array(ismember(chantype_array,settings.lateral.char.b)) = [];
    chantype_array{end+1} = 'pp';
    chantype_array{end+1} = settings.lateral.char.b;
  elseif is_l
    chantype_array(ismember(chantype_array,settings.lateral.char.l)) = [];
    chantype_array{end+1} = 'pp';
    chantype_array{end+1} = settings.lateral.char.l;
  elseif is_r
    chantype_array(ismember(chantype_array,settings.lateral.char.r)) = [];
    chantype_array{end+1} = 'pp';
    chantype_array{end+1} = settings.lateral.char.r;
  else
    chantype_array{end+1} = 'pp';
  end
  chantype_pp = join(chantype_array,'_');
  chantype_pp = chantype_pp{1};
else
  chantype_pp = chantype;
end
end
