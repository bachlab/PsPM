function [sts, out_chan] = pspm_gaze_pp(fn, options)

% ●	Description
% 	pspm_gaze_pp preprocesses gaze signals, gaze x and gaze y channels at
% 	the same time.
% ●	Format
% 	[sts, out_chan] = pspm_gaze_pp(fn) or
% 	[sts, out_chan] = pspm_gaze_pp(fn, options)
% ●	Arguments
% 	              fn: [string] Path to the PsPM file which contains the gaze data.
% 	         options: [struct]
%           .chan: [numeric/string, optional] Channel ID to be preprocessed.
%   .chan_combine: [numeric/string, optional] Channel ID to be combined.
%      .valid_sample: [bool] 1 or 0. 1 if use valid samples produced by
%                     pspm_pupil_pp, 0 if not to use. default as 0.
% ●	Authors
% 	(C) 2021 Teddy Chao (UCL)

%% 1 Initialise
global settings;
if isempty(settings)
  pspm_init;
end
sts = -1;
%% 2 Create default arguments
% 2.1 static variables
list_chans = {'gaze_x_l', 'gaze_x_r', 'gaze_y_l', 'gaze_y_r'};
% 2.2 set default values
if nargin == 1;                        options = struct();              end
if ~isfield(options,'chan');        options.chan = 'gaze_x_l';    end
if ~isfield(options,'chan_action');    options.chan_action = 'add';  end
if ~isfield(options,'chan_combine');   options.chan_combine = 'none';end
if ~isfield(options,'valid_sample');   options.valid_sample = 0;        end
if ~isfield(options, 'plot_data');     options.plot_data = false;       end
if ~isfield(options, 'segments');      options.segments = {};           end
action_combine = ~strcmp(options.chan_combine, 'none');
% 2.3 set default options from pupil_pp
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
[sts, ~, ~, ~] = pspm_load_data(fn, options.chan);
if sts ~= 1
  warning('ID:invalid_chantype', 'cannot load the specified channel from the file');
  return
end
if ~ismember(options.chan_action, {'add', 'replace'})
  warning('ID:invalid_input', ...
    'Option chan_action must be either ''add'' or ''replace''.');
  return
end
if ~ismember(options.chan, list_chans)
  warning('ID:invalid_input', ...
    'Option channel must be either ''gaze_x_l'', ''gaze_x_r'', ''gaze_y_l'' or ''gaze_y_r''.');
  return
end
if action_combine
  if ~ismember(options.chan_combine, list_chans)
    warning('ID:invalid_input', ...
      'Option chan_combine must be either ''gaze_x_l'', ''gaze_x_r'', ''gaze_y_l'' or ''gaze_y_r''.');
    return
  else
    if strcmp(options.chan(end),options.chan_combine(end)) || ...
        ~strcmp(options.chan(6),options.chan_combine(6))
      warning('ID:invalid_input', 'Option chan_combine must match channel.');
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
[~, ~, gaze_og, ~] = pspm_load_data(fn, options.chan);
if action_combine
  [~, ~, gaze_combine, ~] = pspm_load_data(fn, options.chan_combine);
  if gaze_og{1}.header.sr ~= gaze_combine{1}.header.sr
    warning('ID:invalid_input', ...
      'options.chan and options.chan_combine data have different sampling rate');
    return;
  end
  if ~strcmp(gaze_og{1}.header.units, gaze_combine{1}.header.units)
    warning('ID:invalid_input', ...
      'options.chan and options.chan_combine data have different units');
    return;
  end
  if numel(gaze_og{1}.data) ~= numel(gaze_combine{1}.data)
    warning('ID:invalid_input', ...
      'options.chan and options.chan_combine data have different lengths');
    return;
  end
  old_chantype = sprintf('%s and %s', ...
    gaze_og{1}.header.chantype, gaze_combine{1}.header.chantype);
else
  gaze_combine{1}.data = [];
  old_chantype = gaze_og{1}.header.chantype;
end
%% 5 Obtain valid sample from pupil
% obtain valid samples from pupil
if options.valid_sample
  options_pp = options;
  options_pp.chan = 'pupil_l';
  [~, ~, model] = pspm_pupil_pp(fn, options_pp);
  upsampling_factor = options.custom_settings.valid.interp_upsamplingFreq / gaze_og{1}.header.sr;
  desired_output_samples_gaze = round(upsampling_factor * numel(gaze_og{1}.data));
  preprocessed_gaze.header.chantype = pspm_update_chantype(gaze_og{1}.header.chantype,'pp');
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
  preprocessed_gaze.header.chantype = pspm_update_chantype(gaze_og{1}.header.chantype,'pp');
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
  preprocessed_gaze.header.chantype = pspm_update_chantype(gaze_og{1}.header.chantype,{'pp','c'});
  preprocessed_gaze.header.units = gaze_og{1}.header.units;
end
%% 7 save
chan_str = num2str(options.chan);
o.msg.prefix = sprintf(...
  'Gaze preprocessing :: Input channel: %s -- Input chantype: %s -- Output chantype: %s --', ...
  chan_str, ...
  old_chantype, ...
  preprocessed_gaze.header.chantype);
[lsts, out_id] = pspm_write_channel(fn, preprocessed_gaze, options.chan_action, o);
if lsts ~= 1 % if writting channel is unsuccessful
  return
end
out_chan = out_id.chan;
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