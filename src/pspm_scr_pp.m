function [sts, out] = pspm_scr_pp(datafile, options, channel)
% ● Description
%   pspm_scr_pp applies simple skin conductance response (SCR) quality
%   assessment rulesets
%   Rule 1: Microsiemens values must be within range (0.05 to 60)
%   Rule 2: Absolute slope of value change must be less than 10 microsiemens
%           per second
% ● Format
%   [sts, out] = pspm_scr_pp(data, options)
% ● Arguments
%      datafile:  a file name, or cell array of file names
%   [Optional]
%   ┌───options:  A struct with algorithm specific settings.
%   ├──────.min:  Minimum value in microsiemens (default: 0.05).
%   ├──────.max:  Maximum value in microsiemens (default: 60).
%   ├────.slope:  Maximum slope in microsiemens per sec (default: 10).
%   ├.missing_epochs_filename:
%   │             If provided will create a .mat file saving the epochs.
%   │             The path can be specified, but if not the file will be saved
%   │             in the current folder. If saving to the missing epochs file,
%   │             no data in the original datafile will be changed. For
%   │             instance, abc will create abc.mat
%   ├.deflection_threshold:
%   │             Define an threshold in original data units for a slope to pass
%   │             to be considered in the filter. This is useful, for example,
%   │             with oscillatory wave data due to limited A/D bandwidth.
%   │             The slope may be steep due to a jump between voltages but we
%   │             likely do not want to consider this to be filtered.
%   │             A value of 0.1 would filter oscillatory behaviour with
%   │             threshold less than 0.1v but not greater. Default: 0.1
%   ├.data_island_threshold:
%   │             A float in seconds to determine the maximum length of data
%   │             between NaN epochs.
%   │             Islands of data shorter than this threshold will be removed.
%   │             Default: 0 s - no effect on filter
%   ├.expand_epochs:
%   │             A float in seconds to determine by how much data on the flanks
%   │             of artefact epochs will be removed. Default: 0.5 s
%   ├.clipping_step_size:
%   │             A numerical value specifying the step size in moving average
%   │             algorithm for detecting clipping. Default: 2
%   ├.clipping_threshold:
%   │             A float between 0 and 1 specifying the proportion of local
%   │             maximum in a step. Default: 0.1
%   ├.clipping_n_window:
%   │             A numerical value specifying the number of windows in moving average
%   │             algorithm for detecting clipping. Default: 10000
%   ├.change_data:
%   │             A numerical value to choose whether to change the data or not
%   │             Default: 1 (true)
%   ├.channel_action:
%   │             Accepted values: 'add'/'replace'/'withdraw'
%   │             Defines whether the new channel should be added, the previous
%   │             outputs of this function should be replaced, or new data
%   │             should be withdrawn. Default: 'add'.
%   └──.channel:  Number of SCR channel. Default: first SCR channel
% ● Outputs
%           sts:  Status indicating whether the program is running as expected.
%           out:  The path to the  output of the final processed data.
%                 Can be the changed to the data with epochs removed if
%                 options.change_data is set to be positive.
% ● Internal Functions
%   filter_to_epochs
%                 Return the start and end points of epoches (2D array) by the
%                 given filter (1D array).
% ● Key Variables of Internal Functions
%   filt          A filtering array consisting of 0 and 1 for selecting data
%                 whose y and slope are both within the range of interest.
%   filt_epochs   A filtering array consisting of 0 and 1 for selecting epochs.
%   filt_range    A filtering array consisting of 0 and 1 for selecting data
%                 within the range of interest.
%   filt_slope    A filtering array consisting of 0 and 1 for selecting data
%                 whose slope is within the range of interest.
% ● History
%   Introduced In PsPM 5.1
%   Written in 2009-2017 by Tobias Moser (University of Zurich)
%   Updated in 2020 by Samuel Maxwell (UCL)
%                      Dominik R Bach (UCL)
%              2021 by Teddy Chao (UCL)
%   Maintained in 2022 by Teddy Chao (UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
out = [];

%% Set default values
if ~exist('options', 'var')
  options = struct();
end
if nargin < 3 || isempty(channel) || (channel == 0)
  channel = 'scr';
elseif ~isnumeric(channel)
  warning('ID:invalid_input', 'Channel number must be numeric');
  return
end
options = pspm_options(options, 'scr_pp');
if options.invalid
  return
end
%% Sanity checks
if ischar(datafile) || isstruct(datafile)
  data_source = {datafile};
  out = {datafile};
elseif iscell(datafile)
  data_source = datafile;
  out = datafile;
else
  warning('ID:invalid_input', 'Data file must be a char, cell, or struct.');
  return;
end
for d = 1:numel(data_source)
  % out{d} = [];
  [sts_loading, ~, indatas, ~] = pspm_load_data(data_source{d}, channel); % check and get datafile
  if sts_loading == -1
    warning('ID:invalid_input', 'Could not load data');
    return;
  end
  indata = indatas{1,1}.data;
  if ~isfield(indatas{1,1}.header, 'sr')
    warning('ID:invalid_input', 'Input data header must contain the field sample rate (sr).');
    return;
  end
  sr = indatas{1,1}.header.sr; % return sampling frequency from the input data
  if ~any(size(indata) > 1)
    warning('ID:invalid_input', 'Argument ''data'' should contain > 1 data points.');
    return;
  end
  %% Create filters
  data_changed = NaN(size(indata));
  filt_range = indata < options.max & indata > options.min;
  filt_slope = true(size(indata));
  filt_slope(2:end) = abs(diff(indata)*sr) < options.slope;
  if (options.deflection_threshold ~= 0) && ~all(filt_slope==1)
    slope_epochs = filter_to_epochs(filt_slope);
    for r = transpose(slope_epochs)
      if range(indata(r(1):r(2))) < options.deflection_threshold
        filt_slope(r(1):r(2)) = 1;
      end
    end
  end
  [filt_clipping, filt_baseline] = detect_clipping_baseline(indata, options.clipping_step_size, ...
    options.clipping_n_window, options.baseline_jump, options.clipping_threshold);

  if options.include_baseline
    filt_clipping = filt_clipping || filt_baseline;
  end
  % combine filters
  filt = filt_range & filt_slope;
  filt = filt & (1-filt_clipping);
  %% Find data islands and expand artefact islands
  if isempty(find(filt==0, 1))
    warning('Epoch was empty based on the current settings.');
  else
    if options.data_island_threshold > 0 || options.expand_epochs > 0
      % work out data epochs
      filt_epochs = filter_to_epochs(1-filt); % gives data (rather than artefact) epochs
      if options.expand_epochs > 0
        % remove data epochs too short to be shortened
        epoch_duration = diff(filt_epochs, 1, 2);
        filt_epochs(epoch_duration < 2 * ceil(options.expand_epochs * sr), :) = [];
        % shorten data epochs
        filt_epochs(:, 1) = filt_epochs(:, 1) + ceil(options.expand_epochs * sr);
        filt_epochs(:, 2) = filt_epochs(:, 2) - ceil(options.expand_epochs * sr);
      end
      % correct possibly negative values
      filt_epochs(filt_epochs(:, 2) < 1, 2) = 1;
      if options.data_island_threshold > 0
        epoch_duration = diff(filt_epochs, 1, 2);
        filt_epochs(epoch_duration < options.data_island_threshold * sr, :) = [];
      end
      % write back into data
      index(filt_epochs(:, 1)) = 1;
      index(filt_epochs(:, 2)) = -1;
      filt = (cumsum(index(:)) == 1);
      % (thanks Jan: https://www.mathworks.com/matlabcentral/answers/
      % 324955-replace-multiple-intervals-in-array-with-nan-no-loops)
    end
  end
  data_changed(filt) = indata(filt);
  % Compute epochs
  if ~isempty(find(filt == 0, 1))
    epochs = filter_to_epochs(filt);
    epochs = epochs / sr; %convert into seconds
  else
    epochs = [];
  end
  %% Save data
  if ~isempty(options.missing_epochs_filename)
    save(options.missing_epochs_filename, 'epochs');
    % Write epochs to mat if missing_epochs_filename option is present
  else
    % If not save epochs, save the changed data to the original data as
    % a new channel or replace the old data
    if ~strcmp(options.channel_action, 'withdraw')
      data_to_write = indatas{1,1};
      data_to_write.data = data_changed;
      [sts_write, ~] = pspm_write_channel(out{d}, data_to_write, options.channel_action);
      if sts_write == -1
        warning('Epochs were not written to the original file successfully.');
      end
    end
  end
end
sts = 1; % sts is true if all processing above is successful
return

function epochs = filter_to_epochs(filt)    % Return the start and end points of the excluded interval
epoch_on = find(diff(filt) == -1) + 1;      % Return the start points of the excluded interval
epoch_off = find(diff(filt) == 1);          % Return the end points of the excluded interval
if ~isempty(epoch_on) && ~isempty(epoch_off)
  if (epoch_on(end) > epoch_off(end))       % ends on
    epoch_off = [epoch_off; length(filt)];  % Include the end point of the whole data sequence
  end
  if (epoch_on(1) > epoch_off(1))           % starts on
    epoch_on = [ 1; epoch_on ];             % Include the start point of the whole data sequence
  end
elseif ~isempty(epoch_on) && isempty(epoch_off)
  epoch_off = length(filt);
elseif isempty(epoch_on) && ~isempty(epoch_off)
  epoch_on = 1;
end
epochs = [ epoch_on, epoch_off ];

function [index_clipping, index_baseline] = detect_clipping_baseline(data, step_size, n_window, jump, threshold)
l_data = length(data);
window_size = n_window * step_size;
index_window_starter = 1:step_size:(l_data-mod((l_data-window_size),step_size)-window_size-step_size+1);
index_clipping = zeros(l_data,1);
index_baseline = zeros(l_data,1);
for window_starter = index_window_starter
  data_oi_front = data((window_starter+1):(window_starter+window_size));
  data_oi_front_max = max(data_oi_front);
  if sum(data_oi_front==data_oi_front_max)/length(data_oi_front) > threshold
    index_clip_pred = 1:length(data_oi_front);
    index_clip_pred = window_starter + [0,index_clip_pred(data_oi_front==data_oi_front_max)];
    index_clipping(index_clip_pred) = 1;
  end
  if prctile(data_oi_front, 1) > 0
    data_oi_front_jump = data_oi_front_max / prctile(data_oi_front, 1);
    if data_oi_front_jump>jump
      index_clip_pred = 1:length(data_oi_front);
      index_clip_potential = index_clip_pred(data_oi_front>prctile(data_oi_front, 1)*jump);
      if ~isempty(index_clip_potential)
        index_clip_pred = window_starter + index_clip_potential;
        index_baseline(index_clip_pred) = 1;
      end
    end
  end
  
end
