function [sts, outchannel] = pspm_pupil_pp (fn, options)
% ● Description
%   pspm_pupil_pp preprocesses pupil diameter signals given in any unit of
%   measurement. It performs the steps described in [1]. This function uses
%   a modified version of [2]. The modified version with a list of changes
%   from the original is shipped with PsPM under pupil-size directory.
%   The steps performed are listed below:
%   1.  Pupil preprocessing is performed in two main steps. In the first
%       step, the “valid” samples are determined. The samples that are not
%       valid are not used in the second step. Determining valid samples is
%       done by
%       (a) Range filtering: Pupil size values outside a predefined range
%           are considered invalid. This range is configurable.
%       (b) Speed filtering: Speed is computed as the 1st difference of
%           pupil size array normalized by the temporal separation. Samples
%           with speed higher than a threshold are considered invalid. The
%           threshold is configurable.
%       (c) Edge filtering: Samples at both sides of temporal gaps in the
%           data are considered invalid. Both the duration of gaps and the
%           invalid sample duration before/after the gaps are configurable.
%       (d) Trendline filtering: A data trend is generated by smoothing and
%           interpolating the data. Then, samples that are too far away
%           from this trend are considered invalid. These two steps are
%           performed multiple times in an iterative fashion. Note that the
%           generated trend is not the final result of this function. The
%           smoothing, invalid threshold and the number of passes are
%           configurable.
%       (e) Isolated sample filtering: Isolated and small sample islands
%           are considered invalid. The size of the islands and the
%           temporal separation are configurable.
%   2.  In the second step, output smooth signal is generated using the
%       valid samples found in the previous step. This is done by
%       performing filtering, upsampling and interpolation. The parameters
%       of the filtering and upsampling are configurable. Once the pupil
%       data is preprocessed, according to the option 'channel_action',
%       it will either replace an existing preprocessed pupil channel or
%       add it as new channel to the provided file.
% ● Format
%   [sts, channel_index] = pspm_pupil_pp(fn)
%   [sts, channel_index] = pspm_pupil_pp(fn, options)
% ● Arguments
%          fn:  [string]
%               Path to the PsPM file which contains the pupil data.
%   ┌──options: [struct]
%   ├─.channel: [optional][numeric/string] [Default: 'pupil']
%   │           Channel ID to be preprocessed.
%   │           To process a specific eye, use 'pupil_l' or 'pupil_r'.
%   │           To process the combined left and right eye, use 'pupil_c'.
%   │           To combine both eyes, specify one eye here and the other
%   │           under option 'channel_combine'. The identifier 'pupil' will
%   │           use the first existing option out of the following:
%   │           (1) L-R-combined pupil, (2) non-lateralised pupil, (3) best
%   │           eye pupil, (4) any pupil channel. If there are multiple
%   │           channels of the specified type, only last one will be
%   │           processed. You can also specify the number of a channel.
%   ├─.channel_combine:
%   │           [optional][numeric/string][Default: 'none']
%   │           Channel to be used for computing the mean pupil signal.
%   │           The input format is exactly the same as the .channel field.
%   │           However, the eye specified in this channel must be different
%   │           from the one specified in .channel field. The output channel
%   │           will then be of type 'pupil_c'.
%   ├─.channel_action:
%   │           [optional][string][Accepts: 'add'/'replace'][Default: 'add']
%   │           Defines whether corrected data should be added or the
%   │           corresponding preprocessed channel should be replaced.
%   ├─.custom_settings:
%   │           [optional][Default: See pspm_pupil_pp_options]
%   │           Settings structure to modify the preprocessing steps. If
%   │           not specified, the default settings structure obtained from
%   │           <a href="matlab:help pspm_pupil_pp_options">pspm_pupil_pp_options</a>
%   │           will be used. To modify certain fields of this structure,
%   │           you only need to specify those fields in custom_settings.
%   │           For example, to modify settings.raw.PupilMin, you need to
%   │           create a struct with a field .raw.PupilMin.
%   ├─.segments:  [cell array of structures]
%   │           Statistics about user defined segments can be calculated.
%   │           When specified, segments will be stored in .header.segments
%   │           field. Each structure must have the the following fields:
%   ├─.start:   [decimal][Unit: second]
%   │           Starting time of the segment.
%   ├─.end:     [decimal][Unit: second]
%   │           Ending time of the segment.
%   ├─.name:    [string]
%   │           Name of the segment. Segment will be stored by this name.
%   ├─.plot_data:
%   │           [Boolean][Default: false or 0]
%   │           Plot the preprocessing steps if true.
%   ├─.chan_valid_cutoff:
%   │           [optional][Default: 0.01]
%   │           A cut-off value for checking whether there are too many
%   │           missing values in the data channel. Valid data channels 
%   │           should have NaNs fewer than this cut-off value. If
%   │           combination is requested and only one of the two channels has fewer
%   │           than this percentage of missing values, then only this channel will be
%   │           used and no combination will be performed.
%   └.out_chan: Channel ID of the preprocessed output.
% ● Outputs
%      channel_index: index of channel containing the processed data
% ● References
%   [1] Kret, Mariska E., and Elio E. Sjak-Shie. "Preprocessing pupil size
%       data: Guidelines and code." Behavior research methods (2018): 1-7.
%   [2]  https://github.com/ElioS-S/pupil-size
% ● History
%   Introduced in PsPM version ?
%   Written in 2019 by Eshref Yozdemir (University of Zurich)
%              2021 by Teddy
%   Updated in 2024 by Dominik R Bach (Uni Bonn)

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
outchannel = [];

%% 2 Create default arguments
if nargin == 1
  options = struct();
end
options = pspm_options(options, 'pupil_pp');
if options.invalid
  return
end
[lsts, default_settings] = pspm_pupil_pp_options();
if lsts ~= 1
  return
end
if isfield(options, 'custom_settings')
 default_settings = pspm_assign_fields_recursively(...
   default_settings, options.custom_settings);
end
options.custom_settings = default_settings;

%% 3 Input checks
for seg = options.segments
  if ~isfield(seg{1}, 'start') || ~isfield(seg{1}, 'end') || ~isfield(seg{1}, 'name')
    warning('ID:invalid_input', ...
      'Each segment structure must have .start, .end and .name fields');
    return
  end
end
%% 4 Load
action_combine = ~strcmp(options.channel_combine, 'none');
alldata = struct();
[sts_load, alldata.infos, alldata.data] = pspm_load_data(fn);
if sts_load < 1, return, end
[sts_load, data,infos, pos_of_channel(1)] = pspm_load_channel(alldata, options.channel, 'pupil');
if sts_load ~= 1, return, end
flag_valid_data    = sum(isnan(data.data))/length(data.data) < options.chan_valid_cutoff;

if action_combine
  [sts_load, data_combine, infos, pos_of_channel(2)] = pspm_load_channel(alldata, options.channel_combine, 'pupil');
  if sts_load ~= 1
    return
  end
  [sts1, eye1] = pspm_find_eye(data.header.chantype);
  [sts2, eye2] = pspm_find_eye(data_combine.header.chantype);
  if (sts1 < 1 || sts2 < 1), return, end
  if sum(strcmp([eye1, eye2], {'lr', 'rl'})) < 1
    warning('ID:invalid_input', ...
      'options.channel and options.channel_combine must specify left and right eyes.');
    return;
  elseif data.header.sr ~= data_combine.header.sr
    warning('ID:invalid_input', ...
      'options.channel and options.channel_combine data have different sampling rate.');
    return;
  elseif ~strcmp(data.header.units, data_combine.header.units)
    warning('ID:invalid_input', ...
      'options.channel and options.channel_combine data have different units.');
    return;
  elseif numel(data.data) ~= numel(data_combine.data)
    warning('ID:invalid_input', ...
      'options.channel and options.channel_combine data have different lengths.');
    return;
  end

  flag_valid_combine = sum(isnan(data_combine.data))/length(data_combine.data) < options.chan_valid_cutoff;
  if flag_valid_data && ~flag_valid_combine
    warning('ID:invalid_input', ...
      ['data channel is good, ',...
      'but channel_combine channel has more than %s percent missing values, ',...
      'thus it will not be used for combining.'], ...
      num2str(options.chan_valid_cutoff*100));
    data_combine.data = [];
    pos_of_channel = pos_of_channel(1);
  elseif ~flag_valid_data && flag_valid_combine
    warning('ID:invalid_input', ...
      ['channel_combine channel is good, ',...
      'but data channel has more than %s percent missing values, ',...
      'thus only data_combine channel will be used.'], ...
      num2str(options.chan_valid_cutoff*100));
    data = data_combine; % exchange data and data_combine including fields
    data_combine.data = []; % to only use the value stored in data_combine
    pos_of_channel = pos_of_channel(2);
  elseif ~flag_valid_data && ~flag_valid_combine
        warning('ID:invalid_input', ...
      'Both channels have more than %s percent missing values. No combination will be peformed.\nOnly the data channel will be used. Please double-check your output.', num2str(options.chan_valid_cutoff*100));
    data_combine.data = []; % to only use the value stored in data_combine
  end
  old_channeltype = sprintf('%s and %s', ...
    data.header.chantype, data_combine.header.chantype);
else
  data_combine.data = [];
  fprintf('No data to combine provided - only one channel will be used.\n');
  old_channeltype = data.header.chantype;
  if ~flag_valid_data 
    warning('ID:invalid_input', ...
      'Data channel has more than %s percent missing values. Please double-check your output.', num2str(options.chan_valid_cutoff*100));
  end
end
%% 5 preprocess
[lsts, smooth_signal, ~] = pspm_preprocess_pupil(data, data_combine, ...
  options.segments, options.custom_settings, options.plot_data);
if lsts ~= 1
  return
end
%% 6 save
channel_str = num2str(options.channel);
o.msg.prefix = sprintf(...
  'Pupil preprocessing :: Input channel: %s -- Input channeltype: %s -- Output channeltype: %s --', ...
  channel_str, ...
  old_channeltype, ...
  smooth_signal.header.chantype);
% if no new channel type is created, pass channel number to
% pspm_write_channel
if ~strcmpi(smooth_signal.header.chantype, 'pupil_c')
    o.channel = pos_of_channel(1);
end
[sts, out_id] = pspm_write_channel(fn, smooth_signal, options.channel_action, o);
outchannel = out_id.channel;

return

function varargout  = pspm_preprocess_pupil(data, data_combine, segments, custom_settings, plot_data)
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
% 1 definitions
combining = ~isempty(data_combine.data);
data_is_left = strcmpi(pspm_find_eye(data.header.chantype), 'l');
n_samples = numel(data.data);
sr = data.header.sr;
diameter.t_ms = transpose(linspace(0, 1000 * (n_samples-1) / sr, n_samples));
if data_is_left
  diameter.L = data.data;
  diameter.R = data_combine.data;
else
  diameter.L = data_combine.data;
  diameter.R = data.data;
end
if size(diameter.L, 1) == 1
  diameter.L = transpose(diameter.L);
end
if size(diameter.R, 1) == 1
  diameter.R = transpose(diameter.R);
end
segmentStart = transpose(cell2mat(cellfun(@(x) x.start, segments, 'uni', false)));
segmentEnd = transpose(cell2mat(cellfun(@(x) x.end, segments, 'uni', false)));
segmentName = transpose(cellfun(@(x) x.name, segments, 'uni', false));
segmentTable = table(segmentStart, segmentEnd, segmentName);
new_sr = custom_settings.valid.interp_upsamplingFreq;
upsampling_factor = new_sr / sr;
desired_output_samples = round(upsampling_factor * numel(data.data));
% 2 load lib
libbase_path = pspm_path('ext',['pupil', '-size'], 'code');
libpath = {fullfile(libbase_path, 'dataModels'), fullfile(libbase_path, 'helperFunctions')};
addpath(libpath{:});
% 3 filtering
model = PupilDataModel(data.header.units, diameter, segmentTable, 0, custom_settings);
model.filterRawData();
if combining
  smooth_signal.header.chantype = pspm_update_channeltype(data.header.chantype, settings.lateral.char.c);
else
  smooth_signal.header.chantype = data.header.chantype;
end
smooth_signal.header.units = data.header.units;
smooth_signal.header.sr = new_sr;
smooth_signal.header.segments = segments;
% 4 store signal and valid samples
try
  model.processValidSamples();
  if combining
    validsamples_obj = model.meanPupil_ValidSamples;
    smooth_signal.header.valid_samples.data_l = model.leftPupil_ValidSamples.samples.pupilDiameter;
    smooth_signal.header.valid_samples.sample_indices_l = model.leftPupil_RawData.isValid;
    smooth_signal.header.valid_samples.valid_percentage_l = model.leftPupil_ValidSamples.validFraction;
    smooth_signal.header.valid_samples.data_r = model.rightPupil_ValidSamples.samples.pupilDiameter;
    smooth_signal.header.valid_samples.sample_indices_r = model.rightPupil_RawData.isValid;
    smooth_signal.header.valid_samples.valid_percentage_r = model.rightPupil_ValidSamples.validFraction;
  else
    if data_is_left
      validsamples_obj = model.leftPupil_ValidSamples;
      rawdata_obj = model.leftPupil_RawData;
    else
      validsamples_obj = model.rightPupil_ValidSamples;
      rawdata_obj = model.rightPupil_RawData;
    end
    smooth_signal.header.valid_samples.data = validsamples_obj.samples.pupilDiameter;
    smooth_signal.header.valid_samples.sample_indices = find(rawdata_obj.isValid);
    smooth_signal.header.valid_samples.valid_percentage = validsamples_obj.validFraction;
  end
  smooth_signal.data = validsamples_obj.signal.pupilDiameter;
  smooth_signal.data = pspm_complete_with_nans(smooth_signal.data, validsamples_obj.signal.t(1), ...
    new_sr, desired_output_samples);
  % 5 store segment information
  if ~isempty(segments)
    seg_results = model.analyzeSegments();
    seg_results = seg_results{1};
    if combining
      seg_eyes = {'left', 'right', 'mean'};
    elseif data_is_left
      seg_eyes = {'left'};
    else
      seg_eyes = {'right'};
    end
    smooth_signal.header.segments = pspm_store_segment_stats(smooth_signal.header.segments, seg_results, seg_eyes);
  end
  if plot_data
    model.plotData();
  end
catch err
  % https://www.mathworks.com/matlabcentral/answers/225796-rethrow-a-whole-error-as-warning
  warning('ID:invalid_data_structure', getReport(err, 'extended', 'hyperlinks', 'on'));
  smooth_signal.data = NaN(desired_output_samples, 1);
end
rmpath(libpath{:});
sts = 1;
varargout{1} = sts;
switch nargout
  case 2
    varargout{2} = smooth_signal;
  case 3
    varargout{2} = smooth_signal;
    varargout{3} = model;
end
function data = pspm_complete_with_nans(data, t_beg, sr, output_samples)
% Complete the given data that possibly has missing samples at the
% beginning and at the end. The amount of missing samples is determined
% by sampling rate and the data beginning second t_beg.
sec_between_upsampled_samples = 1 / sr;
n_missing_at_the_beg = round(t_beg / sec_between_upsampled_samples);
n_missing_at_the_end = output_samples - numel(data) - n_missing_at_the_beg;
data = [NaN(n_missing_at_the_beg, 1) ; data ; NaN(n_missing_at_the_end, 1)];
function segments = pspm_store_segment_stats(segments, seg_results, seg_eyes)
stat_columns = {...
  'Pupil_SmoothSig_meanDiam', ...
  'Pupil_SmoothSig_minDiam', ...
  'Pupil_SmoothSig_maxDiam', ...
  'Pupil_SmoothSig_missingDataPercent', ...
  'Pupil_SmoothSig_sampleCount', ...
  'Pupil_ValidSamples_meanDiam', ...
  'Pupil_ValidSamples_minDiam', ...
  'Pupil_ValidSamples_maxDiam', ...
  'Pupil_ValidSamples_validPercent', ...
  'Pupil_ValidSamples_sampleCount', ...
  };
for eyestr = seg_eyes
  for colstr = stat_columns
    eyecolstr = [eyestr{1} colstr{1}];
    col = seg_results.(eyecolstr);
    for i = 1:numel(segments)
      segments{i}.(eyecolstr) = col(i);
    end
  end
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
