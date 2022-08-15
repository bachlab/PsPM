function [sts, out_channel] = pspm_blink_saccade_filt(fn, discard_factor, options)
% ● Description
%   Perform blink-saccade filtering on a given file containing pupil data. This
%   function extends each blink and/or saccade period towards the beginning and 
%   the end of the signal by an amount specified by the user.
% ● Format
%   [sts, out_channel] = pspm_blink_saccade_filt(fn, discard_factor, options)
% ● Arguments
%              fn: [string] Path to the PsPM file which contains
%                  the pupil data.
%  discard_factor: [numeric] Factor used to determine the number of
%                  samples right before and right after a blink/saccade
%                  period to discard. This value is multiplied by the
%                  sampling rate of the recording to determine the
%                  number of samples to discard from one end. Therefore,
%                  for each blink/saccade period, 2*this_value*SR many
%                  samples are discarded in total, and effectively
%                  blink/saccade period is extended.
%                  This value also corresponds to the duration of
%                  samples to discard on one end in seconds. For example,
%                  when it is 0.01, we discard 10 ms worth of data on
%                  each end of every blink/saccade period.
%         options:
%        .channel: [numeric/string, optional, default:0]
%                  Channel ID to be preprocessed.
%                  By default preprocesses all the pupil and gaze channels.
% .channel_action: [string, optional, accept:'add'/'replace', default:'add']
%                  Defines whether corrected data should be added or the
%                  corresponding preprocessed channel should be replaced.
% ● Copyright
%   Written by 2020 Eshref Yozdemir (University of Zurich)


global settings;
if isempty(settings), pspm_init; end
sts = -1;
if nargin == 2
  options = struct();
end
if ~isfield(options, 'channel')
  options.channel = 0;
end
if ~isfield(options, 'channel_action')
  options.channel_action = 'add';
end
if ~isnumeric(discard_factor)
  warning('ID:invalid_input', 'discard_factor must be numeric');
  return;
end
if ~ismember(options.channel_action, {'add', 'replace'})
  warning('ID:invalid_input', 'Option channel_action must be either ''add'' or ''replace''');
  return;
end
%% read data
[lsts, ~, data] = pspm_load_data(fn);
if lsts ~= 1; return; end;
[lsts, ~, data_user] = pspm_load_data(fn, options.channel);
if lsts ~= 1; return; end;
data_user = keep_pupil_gaze_chans(data_user);
%% build matrixes and lists
data_mat = {};
column_names = {};
mask_chans = {};
for i = 1:numel(data)
  chantype = data{i}.header.chantype;
  if strncmp(chantype, 'blink', numel('blink')) || ...
      strncmp(chantype, 'saccade', numel('saccade'))
    mask_chans{end + 1} = chantype;
    data_mat{end + 1} = data{i}.data;
    column_names{end + 1} = chantype;
  end
end
n_mask_chans = numel(data_mat);
for i = 1:numel(data_user)
  chantype = data_user{i}.header.chantype;
  should_add = options.channel ~= 0 || ...
    strncmp(chantype, 'pupil', numel('pupil')) || ...
    strncmp(chantype, 'gaze', numel('gaze'));
  if should_add
    data_mat{end + 1} = data_user{i}.data;
    column_names{end + 1} = data_user{i}.header.chantype;
  end
end
data_mat = cell2mat(data_mat);
%% perform filtering
addpath(pspm_path('backroom'));
sr = data{1}.header.sr;
samples_to_discard = round(sr * discard_factor);
out_mat = blink_saccade_filtering(data_mat, column_names, mask_chans, samples_to_discard);
rmpath(pspm_path('backroom'));
%% write back
for i = 1:numel(data_user)
  data_user{i}.data = out_mat(:, n_mask_chans + i);
end
channel_str = options.channel;
if isnumeric(channel_str)
  channel_str = num2str(channel_str);
end
o.msg.prefix = sprintf('Blink saccade filtering :: Input channel: %s', channel_str);
[lsts, out_id] = pspm_write_channel(fn, data_user, options.channel_action, o);
if lsts ~= 1; return; end;
out_channel = out_id.channel;
sts = 1;
%% keep_pupil_gaze_chans
function [out_cell] = keep_pupil_gaze_chans(in_cell)
out_cell = {};
for i = 1:numel(in_cell)
  channel = lower(in_cell{i}.header.chantype);
  if contains(channel, 'pupil') || contains(channel, 'gaze')
    out_cell{end + 1} = in_cell{i};
  end
end