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
%   .channel_combine  [numeric/string, optional] Channel ID to be combined.
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
% load pupil
[~, pupil_l] = pspm_load_single_chan(fn, 'pupil_l', 'last', 'pupil_l');
[~, pupil_r] = pspm_load_single_chan(fn, 'pupil_r', 'last', 'pupil_r');
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

%% 5 Set up smooth signal gaze
% obtain valid samples from pupil
[~, ~, model] = pspm_preprocess(pupil_l, pupil_r, ...
  options.segments, options.custom_settings, options.plot_data, options.channel(1:end-2));
% set up structure for smooth signal gaze
upsampling_factor = options.custom_settings.valid.interp_upsamplingFreq / gaze_og{1}.header.sr;
desired_output_samples_gaze = round(upsampling_factor * numel(gaze_og{1}.data));
smooth_signal_gaze.header.chantype = pspm_update_chantype(gaze_og{1}.header.chantype,'pp');
smooth_signal_gaze.header.units = gaze_og{1}.header.units;
smooth_signal_gaze.header.sr = options.custom_settings.valid.interp_upsamplingFreq;
smooth_signal_gaze.header.segments = options.segments;
smooth_signal_gaze.header.valid_samples.data = model.leftPupil_ValidSamples.samples.pupilDiameter;
smooth_signal_gaze.header.valid_samples.sample_indices = find(model.leftPupil_RawData.isValid);
smooth_signal_gaze.header.valid_samples.valid_percentage = model.leftPupil_ValidSamples.validFraction;

%% 6 preprocess
% gaze_pp obtains the valid sample information from pupil_pp and then use
% it to process gaze signals
smooth_signal_gaze.data = pspm_complete_with_nans(gaze_og{1}.data, model.leftPupil_ValidSamples.signal.t(1), ...
    options.custom_settings.valid.interp_upsamplingFreq, desired_output_samples_gaze);

%% 7 save
channel_str = num2str(options.channel);
o.msg.prefix = sprintf(...
  'Gaze preprocessing :: Input channel: %s -- Input chantype: %s -- Output chantype: %s --', ...
  channel_str, ...
  old_chantype, ...
  smooth_signal_gaze.header.chantype);
[lsts, out_id] = pspm_write_channel(fn, smooth_signal_gaze, options.channel_action, o);
if lsts ~= 1
  return
end
out_channel = out_id.channel;
sts = 1;
end
