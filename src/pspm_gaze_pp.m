function [sts, out_channel] = pspm_gaze_pp(fn, options)

% ●	Description
% 	pspm_gaze_pp preprocesses gaze signals, gaze x and gaze y channels at
% 	the same time.
% ●	Format
% 	[sts, out_channel] = pspm_gaze_pp(fn) or
% 	[sts, out_channel] = pspm_gaze_pp(fn, options)
% ●	Arguments
% 	fn				[string] Path to the PsPM file which contains the gaze data.
% 	options
%   .channel  [numeric/string, optional] Channel ID to be preprocessed.
% ●	Authors
% 	(C) 2021 Teddy Chao

%% 1 Initialise
global settings;
if isempty(settings)
  pspm_init;
end
sts = -1;

%% 2 Create default arguments
list_channels = {'gaze_x_l', 'gaze_x_r', 'gaze_y_l', 'gaze_y_r'};
if nargin == 1
  options = struct();
end
if ~isfield(options, 'channel')
  options.channel = 'gaze_x_l';
end
if ~isfield(options, 'channel_action')
  options.channel_action = 'add';
end
if ~isfield(options, 'channel_combine')
  options.channel_combine = 'none';
end
action_combine = ~strcmp(options.channel_combine, 'none');
if ~isfield(options, 'plot_data')
  options.plot_data = false;
end
[lsts, default_settings] = pspm_pupil_pp_options();
if lsts ~= 1
  return
end
if isfield(options, 'custom_settings')
  default_settings = pspm_assign_fields_recursively(default_settings, options.custom_settings);
end
options.custom_settings = default_settings;
if ~isfield(options, 'segments')
  options.segments = {};
end

%% 3 Input checks
% 3.1 check the file exist
[sts, ~, ~, ~] = pspm_load_data(fn);
if sts ~= 1
  warning('ID:invalid_input', 'cannot load data from the file');
  return
end
% 3.2 check the channel can be loaded
[sts, ~, ~, ~] = pspm_load_data(fn, options.channel);
if sts ~= 1
  warning('ID:invalid_channeltype', 'cannot load the specified channel from the file');
  return
end
if ~ismember(options.channel_action, {'add', 'replace'})
  warning('ID:invalid_input', ...
    'Option channel_action must be either ''add'' or ''replace''.');
  return
end
if ~ismember(options.channel, list_channels)
  warning('ID:invalid_input', ...
    'Option channel must be either ''gaze_x_l'', ''gaze_x_r'', ''gaze_y_l'' or ''gaze_y_r''.');
  return
end
if action_combine
  if ~ismember(options.channel_combine, list_channels)
    warning('ID:invalid_input', ...
      'Option channel_combine must be either ''gaze_x_l'', ''gaze_x_r'', ''gaze_y_l'' or ''gaze_y_r''.');
    return
  else
    if strcmp(options.channel(end),options.channel_combine(end)) || ~strcmp(options.channel(6),options.channel_combine(6))
      warning('ID:invalid_input', 'Option channel_combine must match channel.');
      return
    end
  end
end
for seg = options.segments
  if ~isfield(seg{1}, 'start') || ~isfield(seg{1}, 'end') || ~isfield(seg{1}, 'name')
    warning('ID:invalid_input', ...
      'Each segment structure must have .start, .end and .name fields');
    return
  end
end

%% 4 Load
addpath(pspm_path('backroom'));
[~, gaze_og] = pspm_load_single_chan(fn, options.channel, 'last', options.channel);
if action_combine
  [~, gaze_combine] = pspm_load_single_chan(fn, options.channel_combine, 'last', options.channel_combine);
  if gaze_og{1}.header.sr ~= gaze_combine{1}.header.sr
    warning('ID:invalid_input', 'options.channel and options.channel_combine data have different sampling rate');
    return;
  end
  if ~strcmp(gaze_og{1}.header.units, gaze_combine{1}.header.units)
    warning('ID:invalid_input', 'options.channel and options.channel_combine data have different units');
    return;
  end
  if numel(gaze_og{1}.data) ~= numel(gaze_combine{1}.data)
    warning('ID:invalid_input', 'options.channel and options.channel_combine data have different lengths');
    return;
  end
  old_chantype = sprintf('%s and %s', gaze_og{1}.header.chantype, gaze_combine{1}.header.chantype);
else
  gaze_combine{1}.data = [];
  old_chantype = gaze_og{1}.header.chantype;
end
rmpath(pspm_path('backroom'));

%% 5 preprocess
[lsts, smooth_signal] = pspm_preprocess(gaze_og, gaze_combine, ...
  options.segments, options.custom_settings, options.plot_data, options.channel(1:end-2));
if lsts ~= 1
  return
end

%% 6 save
channel_str = num2str(options.channel);
o.msg.prefix = sprintf(...
  'Gaze preprocessing :: Input channel: %s -- Input chantype: %s -- Output chantype: %s --', ...
  channel_str, ...
  old_chantype, ...
  smooth_signal.header.chantype);
[lsts, out_id] = pspm_write_channel(fn, smooth_signal, options.channel_action, o);
if lsts ~= 1
  return
end
out_channel = out_id.channel;
sts = 1;
end
