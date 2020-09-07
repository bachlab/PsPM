function [sts, out] = pspm_simple_qa(data, sr, options)
% pspm_simple_qa applies simple SCR quality assessment rulesets
% Rule 1:       Microsiemens values must be within range (0.05 to 60)
% Rule 2:       Absolute slope of value change must be less than 10
%               microsiemens per second
%
% FORMAT: 
%   [sts, out] = pspm_simple_qa(data, sr, options)
%
% ARGUMENTS:
%       data:                           A numeric vector. Data should be in
%                                       microsiemens.
%       sr:                             Samplerate of the data. This is needed to
%                                       determine the slopes unit.
%       options:                        A struct with algorithm specific settings.
%           min:                        Minimum value in microsiemens (default: 0.05).
%           max:                        Maximum value in microsiemens (default: 60).
%           slope:                      Maximum slope in microsiemens per sec (default: 10).
%           missing_epochs_filename:    If provided will create a .mat file with the missing epochs,
%                                       e.g. abc will create abc.mat
%           deflection_threshold:       Define an threshold in original data units for a slope to pass to be considerd in the filter.
%                                       This is useful, for example, with oscillatory wave data due to limited A/D bandwidth
%                                       The slope may be steep due to a jump between voltages but we
%                                       likely do not want to consider this to be filtered.
%                                       A value of 0.1 would filter oscillatory behaviour with threshold less than 0.1v but not greater
%                                       Default: 0 - ie will take no effect on filter
%           data_island_threshold:      A float in seconds to determine the maximum length of data between NaN epochs. Islands of data
%                                       shorter than this threshold will be removed. 
%                                       Default: 0 s - no effect on filter
%           expand_epochs:              A float in seconds to determine by how much data on the flanks of artefact epochs will be removed.
%                                       Default: 0.5 s
%           
%                                       
%__________________________________________________________________________
% PsPM 5.0
% 2009-2017 Tobias Moser (University of Zurich)
% 2020 Samuel Maxwell & Dominik Bach (UCL)

% $Id: pspm_pp.m 450 2017-07-03 15:17:02Z tmoser $   
% $Rev: 450 $

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end
out = [];
sts = -1;


% set default values
if ~exist('options', 'var')
    options = struct();
end

if ~isfield(options, 'min')
    options.min = 0.05;
end

if ~isfield(options, 'max')
    options.max = 60;
end

if ~isfield(options, 'slope')
    options.slope = 10;
end

if ~isfield(options, 'deflection_threshold')
    options.deflection_threshold = 0;
end

if ~isfield(options, 'data_island_threshold')
    options.data_island_threshold = nan;
end

if ~isfield(options, 'expand_epochs')
    options.expand_epochs = 0;
end

% sanity checks
if ~isnumeric(data)
    warning('ID:invalid_input', 'Argument ''data'' must be numeric.'); return;
elseif ~isnumeric(sr)
    warning('ID:invalid_input', 'Argument ''sr'' must be numeric.'); return;
elseif ~any(size(data) > 1)
    warning('ID:invalid_input', 'Argument ''data'' should contain > 1 data points.'); return;
elseif ~isnumeric(options.min)
    warning('ID:invalid_input', 'Argument ''options.min'' must be numeric.'); return;
elseif ~isnumeric(options.max)
    warning('ID:invalid_input', 'Argument ''options.max'' must be numeric.'); return;
elseif ~isnumeric(options.slope)
    warning('ID:invalid_input', 'Argument ''options.slope'' must be numeric.'); return;
elseif isfield(options, 'missing_epochs_filename')
    if ~ischar(options.missing_epochs_filename)
        warning('ID:invalid_input', 'Argument ''options.missing_epochs_filename'' must be char array.'); return;
    end
    
    [pth, ~, ext] = fileparts(options.missing_epochs_filename);
    if ~isempty(pth) && exist(pth,'dir')~=7
        warning('ID:invalid_input','Please specify a valid output directory if you want to save artefact epochs.')
        return;
    end
    if ~isempty(ext)
        warning('ID:invalid_input','Please specify a valid filename (without extension) if you want to save artefact epochs.')
        return;
    end
end

% create filters
d = NaN(size(data));
range_filter = data < options.max & data > options.min;
slope_filter = true(size(data));
diff_data = diff(data);
slope_filter(2:end) = abs(diff_data*sr) < options.slope;

if (options.deflection_threshold ~= 0)

    slope_epochs = filter_to_epochs(slope_filter);
    for r = slope_epochs'
        if range(data(r(1):r(2))) < options.deflection_threshold
            slope_filter(r(1):r(2)) = 1;
        end
    end

end

% combine filters
filt = range_filter & slope_filter;

% find data islands and expand artefact islands
if options.data_island_threshold > 0 || options.expand_epochs > 0
    
    % work out data epochs
    data_epochs = filter_to_epochs(1-filt); % gives data (rather than artefact) epochs

    if options.expand_epochs > 0
        % remove data epochs too short to be shortened
        epoch_duration = diff(data_epochs, 1, 2);
        data_epochs(epoch_duration < 2 * ceil(options.expand_epochs * sr), :) = [];
        % shorten data epochs
        data_epochs(:, 1) = data_epochs(:, 1) + ceil(options.expand_epochs * sr);
        data_epochs(:, 2) = data_epochs(:, 2) - ceil(options.expand_epochs * sr);
    end
    
    % correct possibly negative values
    data_epochs(data_epochs(:, 2) < 1, 2) = 1;
    
    if options.data_island_threshold > 0
        epoch_duration = diff(data_epochs, 1, 2);
        data_epochs(epoch_duration < options.data_island_threshold * sr, :) = [];
    end
    
    
    % write back into data
    index(data_epochs(:, 1)) = 1;
    index(data_epochs(:, 2)) = -1; 
    filt = (cumsum(index(:)) == 1); % (thanks Jan: https://www.mathworks.com/matlabcentral/answers/324955-replace-multiple-intervals-in-array-with-nan-no-loops)
end    
    

d(filt) = data(filt);

% write epochs to mat if missing_epochs_filename option is present
if isfield(options, 'missing_epochs_filename')
    if ~isempty(find(filt == 0, 1))
        epochs = filter_to_epochs(filt);
    else
        epochs = [];
    end

    save(options.missing_epochs_filename, 'epochs');
end

out = d;
sts = 1;

end

function epochs = filter_to_epochs(filt)
epoch_on = find(diff(filt) == -1) + 1;
epoch_off = find(diff(filt) == 1);

% ends on
if (epoch_on(end) > epoch_off(end))
    epoch_off(end + 1) = length(filt);
end

% starts on
if (epoch_on(1) > epoch_off(1))
    epoch_on = [ 1; epoch_on ];
end

epochs = [ epoch_on, epoch_off ];
end