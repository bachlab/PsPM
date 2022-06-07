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
% 		channel	[numeric/string, optional] Channel ID to be preprocessed.
% ●	Authors
% 	(C) 2021 Teddy Chao

%% 1 Initialise
global settings;
if isempty(settings)
  pspm_init;
end
sts = -1;

%% 2 Create default arguments
if nargin == 1
  options = struct();
end
if ~isfield(options, 'channel')
  options.channel = 'gaze_l';
end
if ~isfield(options, 'channel_action')
  options.channel_action = 'add';
end
if ~isfield(options, 'channel_combine')
  options.channel_combine = 'none';
end
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
if ~ismember(options.channel_action, {'add', 'replace'})
  warning('ID:invalid_input', ...
    'Option channel_action must be either ''add'' or ''replace''');
  return
end
for seg = options.segments
  if ~isfield(seg{1}, 'start') || ~isfield(seg{1}, 'end') || ~isfield(seg{1}, 'name')
    warning('ID:invalid_input', ...
      'Each segment structure must have .start, .end and .name fields');
    return
  end
end

%% 4 Load
action_combine = ~strcmp(options.channel_combine, 'none');
addpath(pspm_path('backroom'));
[lsts, gaze_original] = pspm_load_single_chan(fn, options.channel, 'last', 'gaze_x');
if lsts ~= 1
  return
end
if action_combine
  [lsts, gaze_combine] = pspm_load_single_chan(fn, options.channel_combine, 'last', 'gaze_x');
  if lsts ~= 1
    return
  end
  if strcmp(pspm_get_eye(gaze_original{1}.header.chantype), pspm_get_eye(gaze_combine{1}.header.chantype))
    warning('ID:invalid_input', 'options.channel and options.channel_combine must specify different eyes');
    return;
  end
  if gaze_original{1}.header.sr ~= gaze_combine{1}.header.sr
    warning('ID:invalid_input', 'options.channel and options.channel_combine data have different sampling rate');
    return;
  end
  if ~strcmp(gaze_original{1}.header.units, gaze_combine{1}.header.units)
    warning('ID:invalid_input', 'options.channel and options.channel_combine data have different units');
    return;
  end
  if numel(gaze_original{1}.data) ~= numel(gaze_combine{1}.data)
    warning('ID:invalid_input', 'options.channel and options.channel_combine data have different lengths');
    return;
  end
  old_chantype = sprintf('%s and %s', gaze_original{1}.header.chantype, gaze_combine{1}.header.chantype);
else
  gaze_combine{1}.data = [];
  old_chantype = gaze_original{1}.header.chantype;
end
rmpath(pspm_path('backroom'));

%% 5 preprocess
[lsts, smooth_signal] = pspm_preprocess(gaze_original, gaze_combine, options.segments, options.custom_settings, options.plot_data, 'gaze_x');
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
