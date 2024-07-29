function [sts, out] = pspm_scr_pp(datafile, options)
% ● Description
%   pspm_scr_pp applies simple skin conductance response (SCR) quality
%   assessment rulesets.
%   Rule 1: Microsiemens values must be within range (0.05 to 60)
%   Rule 2: Absolute slope of value change must be less than 10 microsiemens
%           per second
%   If option.missing_epochs_filename is specified, the detected epochs
%   will be written to a missing epochs file to be used for GLM
%   (recommended). Otherwise, the respective data will be changed to NaN.
% ● Format
%   [sts, channel_index]       = pspm_scr_pp(data, options)
%   [sts, missing_epochs_file] = pspm_scr_pp(data, options)
% ● Arguments
%   *  datafile:  a file name
%   ┌─────── options
%   ├───────.channel: [optional, numeric/string, default: 'scr', i.e. last
%   │                 SCR channel in the file]
%   │                 Channel type or channel ID to be preprocessed.
%   │                 Channel can be specified by its index (numeric) in the
%   │                 file, or by channel type (string).
%   │                 If there are multiple channels with this type, only
%   │                 the last one will be processed. If you want to
%   │                 preprocess several SCR in a PsPM file,
%   │                 call this function multiple times with the index of
%   │                 each channel.  In this case, set the option
%   │                 'channel_action' to 'add',  to store each
%   │                 resulting 'scr' channel separately.
%   ├──────.min:  [Optional] Minimum value in microsiemens (default: 0.05).
%   ├──────.max:  [Optional] Maximum value in microsiemens (default: 60).
%   ├────.slope:  [Optional] Maximum slope in microsiemens per sec (default: 10).
%   ├.missing_epochs_filename:
%   │             [Optional] If provided will create a .mat file saving the epochs.
%   │             The path can be specified, but if not the file will be saved
%   │             in the current folder. If saving to the missing epochs file,
%   │             no data in the original datafile will be changed. For
%   │             instance, abc will create abc.mat
%   ├.deflection_threshold:
%   │             [Optional] Define an threshold in original data units for a slope to pass
%   │             to be considered in the filter. This is useful, for example,
%   │             with oscillatory wave data due to limited A/D bandwidth.
%   │             The slope may be steep due to a jump between voltages but we
%   │             likely do not want to consider this to be filtered.
%   │             A value of 0.1 would filter oscillatory behaviour with
%   │             threshold less than 0.1v but not greater. Default: 0.1
%   ├.data_island_threshold:
%   │             [Optional] A float in seconds to determine the maximum length of data
%   │             between NaN epochs.
%   │             Islands of data shorter than this threshold will be removed.
%   │             Default: 0 s - no effect on filter
%   ├.expand_epochs:
%   │             [Optional] A float in seconds to determine by how much data on the flanks
%   │             of artefact epochs will be removed. Default: 0.5 s
%   ├.clipping_step_size:
%   │             [Optional] A numerical value specifying the step size in moving average
%   │             algorithm for detecting clipping. Default: 10
%   ├.clipping_window_size:
%   │             [Optional] A numerical value specifying the window size in moving average
%   │             algorithm for detecting clipping. Default: 100
%   ├.clipping_threshold:
%   │             [Optional] A float between 0 and 1 specifying the proportion of local
%   │             maximum in a step. Default: 0.1
%   ├.baseline_jump:
%   │             [Optional] A numerical value to determine how many times of data
%   │             jumpping will be considered for detecting baseline
%   │             alteration. For example, when .baseline is set to be 2,
%   │             if the maximum value of the window is more than 2 times
%   │             than the 5% percentile of the values in the window, such
%   │             periods will be considered as baseline alteration.
%   │             Default: 1.5
%   ├.include_baseline:
%   │             [Optional] A bool value to determine if detected baseline alteration
%   │             will be included in the calculated clippings.
%   │             Default: 0 (not to include baseline alteration in clippings)
%   ├─.overwrite: [logical] (0 or 1)
%   │             [Optional] Define whether to overwrite existing missing epochs files 
%   │             or not (default). Will only be used if
%   │             options.missing_epochs_filename is specified.
%   └.channel_action:
%                 [Optional] Accepted values: 'add'/'replace'
%                 Defines whether the new channel should be added or the previous
%                 outputs of this function should be replaced. Default: 'add'. 
%                 Will not be used if options.missing_epochs_filename is 
%                 specified.
% ● Outputs
%   *  channel_index: index of channel containing the processed data
%   *  missing_epochs_file: file that contains the missing epochs
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
%   Written in 2017      by Tobias Moser (University of Zurich)
%   Updated in 2020      by Samuel Maxwell (UCL)
%              2021-2024 by Teddy

%% Initialise
global settings
if isempty(settings)
    pspm_init;
end
sts = -1;
out = [];

%% Set default values
if nargin < 1
    warning('ID:invalid_input', 'No input. Don''t know what to do.'); return;
elseif nargin < 2
    options = struct();
end
options = pspm_options(options, 'scr_pp');
if options.invalid
    return
end

%% Sanity checks
[sts_loading, indatas, infos, pos_of_channel] = pspm_load_channel(datafile, options.channel, 'scr'); % check and get datafile
if sts_loading == -1
    return;
end
indata = indatas.data;
sr = indatas.header.sr; % return sampling frequency from the input data
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
    options.clipping_window_size, options.baseline_jump, options.clipping_threshold);
if options.include_baseline
    filt_clipping = filt_clipping | filt_baseline;
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
    % Write epochs to mat if missing_epochs_filename option is present
    if ~pspm_overwrite(options.missing_epochs_filename, options)
        warning('ID:invalid_input', 'Missing epoch file exists, and overwriting not allowed by user.');
        return
    else
        save(options.missing_epochs_filename, 'epochs');
        out = options.missing_epochs_filename;
    end
else
    % If not save epochs, save the changed data to the original data as
    % a new channel or replace the old data
    data_to_write = indatas;
    data_to_write.data = data_changed;
    [sts_write, outinfos] = pspm_write_channel(datafile, data_to_write, options.channel_action, struct('channel', pos_of_channel));
    if sts_write == -1
        warning('Epochs were not written to the original file successfully.');
        return
    end
    out = outinfos.channel;
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

function [index_clipping, index_baseline] = detect_clipping_baseline(data, step_size, window_size, jump, threshold)
l_data = length(data);
n_window = floor((l_data-window_size) / step_size);
index_window_starter = 1:step_size:(step_size*n_window+1);
index_clipping = zeros(l_data,1);
index_baseline = zeros(l_data,1);
index_baseline_starter = [];
index_baseline_end = [];
for window_starter = index_window_starter
    data_windowed = data(window_starter:(window_starter+window_size)-1);
    data_windowed_max = max(data_windowed);
    index_pred = (1:length(data_windowed))+window_starter-1;
    if sum(data_windowed==data_windowed_max)/length(data_windowed) > threshold % detect clipping
        index_clipping(index_pred) = 1;
    end
    if prctile(data_windowed, 1)>0 && (data_windowed_max / prctile(data_windowed, 1))>jump % detect baseline
        if max(diff(data_windowed))>jump*prctile(data_windowed, 1) && ...
                (min(diff(data_windowed))<jump*prctile(data_windowed, 1)*(-1))
            target = find(diff(data_windowed)==max(diff(data_windowed)));
            target = target(1);
            index_baseline_starter(end+1) = index_pred(target+1);
            target = find(diff(data_windowed)==min(diff(data_windowed)));
            target = target(1);
            index_baseline_end(end+1) = index_pred(target);
        end
    end
end
if ~isempty(index_baseline_starter)
    C=cellfun(@(x,y)x:y,num2cell(index_baseline_starter),num2cell(index_baseline_end),'uni',false);
    index_baseline([C{:}])=1;
end
