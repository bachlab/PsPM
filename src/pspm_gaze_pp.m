function [sts, out_channel] = pspm_gaze_pp(fn, options)
% ●	Description
% 	pspm_gaze_pp preprocesses gaze signals, gaze x and gaze y channels at
% 	the same time.
% ●	Format
% 	[sts, out_channel] = pspm_gaze_pp(fn) or
% 	[sts, out_channel] = pspm_gaze_pp(fn, options)
% ●	Arguments
% 	              fn: [string] Path to the PsPM file which contains the gaze data.
% 	         options: [struct]
%           .channel: [numeric/string, optional] Channel ID to be preprocessed.
%   .channel_combine: [numeric/string, optional] Channel ID to be combined.
%      .valid_sample: [bool] 1 or 0. 1 if use valid samples produced by
%                     pspm_pupil_pp, 0 if not to use. default as 0.
% ●	History
% 	Written in 2021 by Teddy Chao (UCL)

%% 1 Initialise
global settings;
if isempty(settings)
  pspm_init;
end
sts = -1;
%% 2 Create default arguments
% 2.1 set default values
if nargin == 1
  options = struct();
end
options = pspm_options(options, 'gaze_pp');
if options.invalid
  return
end

action_combine = ~strcmp(options.channel_combine, 'none');
% 2.2 set default options from pupil_pp
[lsts, default_settings] = pspm_pupil_pp_options();
if lsts ~= 1
  return
end
if isfield(options, 'custom_settings')
  default_settings = pspm_assign_fields_recursively( ...
    default_settings, options.custom_settings);
end
options.custom_settings = default_settings;
%% 3 Input checks
% 3.1 check the file exist
[sts, ~, ~, ~] = pspm_load_data(fn);
if sts ~= 1; warning('ID:invalid_input', 'cannot load data from the file'); return; end
% 3.2 check the channel can be loaded
[sts, ~, ~, ~] = pspm_load_data(fn, options.channel);
if sts ~= 1
  warning('ID:invalid_channeltype', 'cannot load the specified channel from the file');
  return
end
if action_combine
  if strcmp(options.channel(end),options.channel_combine(end)) || ...
      ~strcmp(options.channel(6),options.channel_combine(6))
    warning('ID:invalid_input', 'Option channel_combine must match channel.');
    return
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
[~, ~, gaze_og, ~] = pspm_load_data(fn, options.channel);
if action_combine
  [~, ~, gaze_combine, ~] = pspm_load_data(fn, options.channel_combine);
  if gaze_og{1}.header.sr ~= gaze_combine{1}.header.sr
    warning('ID:invalid_input', ...
      'options.channel and options.channel_combine data have different sampling rate');
    return;
  end
  if ~strcmp(gaze_og{1}.header.units, gaze_combine{1}.header.units)
    warning('ID:invalid_input', ...
      'options.channel and options.channel_combine data have different units');
    return;
  end
  if numel(gaze_og{1}.data) ~= numel(gaze_combine{1}.data)
    warning('ID:invalid_input', ...
      'options.channel and options.channel_combine data have different lengths');
    return;
  end
  old_channeltype = sprintf('%s and %s', ...
    gaze_og{1}.header.channeltype, gaze_combine{1}.header.channeltype);
else
  gaze_combine{1}.data = [];
  old_channeltype = gaze_og{1}.header.channeltype;
end
%% 5 Obtain valid sample from pupil
% obtain valid samples from pupil
if options.valid_sample
  options_pp = options;
  options_pp.channel = 'pupil_l';
  [~, ~, model] = pspm_pupil_pp(fn, options_pp);
  upsampling_factor = options.custom_settings.valid.interp_upsamplingFreq / gaze_og{1}.header.sr;
  desired_output_samples_gaze = round(upsampling_factor * numel(gaze_og{1}.data));
  preprocessed_gaze.header.channeltype = pspm_update_channel_type(gaze_og{1}.header.channeltype,'pp');
  preprocessed_gaze.header.units = gaze_og{1}.header.units;
  preprocessed_gaze.header.sr = options.custom_settings.valid.interp_upsamplingFreq;
  preprocessed_gaze.header.segments = options.segments;
  preprocessed_gaze.header.valid_samples.data = model.leftPupil_ValidSamples.samples.pupilDiameter;
  preprocessed_gaze.header.valid_samples.sample_indices = find(model.leftPupil_RawData.isValid);
  preprocessed_gaze.header.valid_samples.valid_percentage = model.leftPupil_ValidSamples.validFraction;
end
%% 6 preprocess
% gaze_pp obtains the valid sample information from pupil_pp and then use
% it to process gaze signals
if ~action_combine
  if options.valid_sample
    preprocessed_gaze.data = pspm_cmpnans(gaze_og{1}.data, model.leftPupil_ValidSamples.signal.t(1), ...
      options.custom_settings.valid.interp_upsamplingFreq, desired_output_samples_gaze);
    preprocessed_gaze.header.sr = options.custom_settings.valid.interp_upsamplingFreq;
  else
    preprocessed_gaze.data = gaze_og{1}.data;
    preprocessed_gaze.header.sr = gaze_og{1}.header.sr;
  end
  preprocessed_gaze.header.channeltype = pspm_update_channel_type(gaze_og{1}.header.channeltype,'pp');
  preprocessed_gaze.header.units = gaze_og{1}.header.units;
else
  if options.valid_sample
    preprocessed_gaze.data = pspm_cmpnans(...
      gaze_og{1}.data, ...
      model.leftPupil_ValidSamples.signal.t(1), ...
      options.custom_settings.valid.interp_upsamplingFreq, ...
      desired_output_samples_gaze);
    preprocessed_gaze_combine.data = pspm_cmpnans(...
      gaze_combine{1}.data, ...
      model.leftPupil_ValidSamples.signal.t(1), ...
      options.custom_settings.valid.interp_upsamplingFreq, ...
      desired_output_samples_gaze);
    preprocessed_gaze.header.sr = options.custom_settings.valid.interp_upsamplingFreq;
  else
    preprocessed_gaze.data = gaze_og{1}.data;
    preprocessed_gaze_combine.data = gaze_combine{1}.data;
    preprocessed_gaze.header.sr = gaze_og{1}.header.sr;
  end
  preprocessed_gaze.data = transpose(mean(transpose([preprocessed_gaze.data, preprocessed_gaze_combine.data]),'omitnan'));
  preprocessed_gaze.header.channeltype = pspm_update_channeltype(gaze_og{1}.header.channeltype,{'pp','c'});
  preprocessed_gaze.header.units = gaze_og{1}.header.units;
end
%% 7 save
channel_str = num2str(options.channel);
o.msg.prefix = sprintf(...
  'Gaze preprocessing :: Input channel: %s -- Input channeltype: %s -- Output channeltype: %s --', ...
  channel_str, ...
  old_channeltype, ...
  preprocessed_gaze.header.channeltype);
[lsts, out_id] = pspm_write_channel(fn, preprocessed_gaze, options.channel_action, o);
if ~lsts % if writting channel is unsuccessful
  return
end
%% Return values
out_channel = out_id.channel;
sts = 1;
end

function data = pspm_cmpnans(data, t_beg, sr, output_samples)
% complete with NaNs
% Complete the given data that possibly has missing samples at the
% beginning and at the end. The amount of missing samples is determined
% by sampling rate and the data beginning second t_beg.
sec_between_upsampled_samples = 1 / sr;
n_missing_at_the_beg = round(t_beg / sec_between_upsampled_samples);
n_missing_at_the_end = output_samples - numel(data) - n_missing_at_the_beg;
data = [NaN(n_missing_at_the_beg, 1) ; data ; NaN(n_missing_at_the_end, 1)];
end
function out_struct = pspm_assign_fields_recursively(out_struct, in_struct)
% Definition
% pspm_assign_fields_recursively assign all fields of in_struct to
% out_struct recursively, overwriting when necessary.
fnames = fieldnames(in_struct);
for i = 1:numel(fnames)
  name = fnames{i};
  if isstruct(in_struct.(name)) && isfield(out_struct, name)
    out_struct.(name) = pspm_assign_fields_recursively(out_struct.(name), in_struct.(name));
  else
    out_struct.(name) = in_struct.(name);
  end
end
end
