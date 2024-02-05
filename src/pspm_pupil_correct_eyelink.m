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
%   │ * mandatory
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
%   │ * optional
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
% ● History
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

%% create default arguments
options = pspm_options(options, 'pupil_correct_eyelink');
if options.invalid
  return
end

if strcmp(options.mode, 'manual')
  for field = all_fieldnames
    if ~isfield(options, field{1}) || options.(field{1}) == 0
      warning('ID:invalid_input',...
        'In manual mode, options must contain all geometry parameters');
      return;
    end
  end
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
[lsts, pupil_data] = pspm_load_channel(fn, options.channel, 'pupil');
if lsts ~= 1, return, end
old_channeltype = pupil_data.header.chantype;

is_left = contains(old_channeltype, '_l');
is_both = contains(old_channeltype, '_c');
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

[lsts, gaze_x_data] = pspm_load_channel(fn, gaze_x_chan, 'gaze_x');
if lsts ~= 1; return; end
[lsts, gaze_y_data] = pspm_load_channel(fn, gaze_y_chan, 'gaze_y');
if lsts ~= 1; return; end

%% conditionally mandatory input checks

if strcmp(gaze_x_data.header.units, 'pixel') || strcmp(gaze_y_data.header.units, 'pixel')
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

gaze_x_mm = get_gaze_in_mm(gaze_x_data.data,...
  gaze_x_data.header.units, options.screen_size_mm(1),...
  options.screen_size_px(1));
gaze_y_mm = get_gaze_in_mm(gaze_y_data.data,...
  gaze_y_data.header.units, options.screen_size_mm(2),...
  options.screen_size_px(2));
pupil = pupil_data.data;

%% correction
[sts_pupil_correct, pupil_corrected] = pspm_pupil_correct(pupil, gaze_x_mm, gaze_y_mm, options);
if sts_pupil_correct ~= 1; return; end

%% save data
pupil_data.data = pupil_corrected;
pupil_data.header.chantype = old_channeltype;
channel_str = num2str(options.channel);
o.msg.prefix = sprintf(...
  'PFE correction :: Input channel: %s -- Input channeltype: %s -- Output channeltype: %s --', ...
  channel_str, ...
  old_channeltype, ...
  pupil_data.header.chantype);
[lsts, out_id] = pspm_write_channel(fn, pupil_data, options.channel_action, o);
if lsts ~= 1; return; end

out_channel = out_id.channel;
sts = 1;
return

function gaze_mm = get_gaze_in_mm(gaze_data, units, side_mm, side_px)
if strcmp(units, 'pixel')
  gaze_mm = gaze_data * (side_mm / side_px);
else
  [~, gaze_mm] = pspm_convert_unit(gaze_data, units, 'mm');
end


