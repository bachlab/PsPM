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
%                                       This is useful, for example, with oscillatory wave data
%                                       The slope may be steep due to a jump between voltages but we
%                                       likely do not want to consider this to be filtered.
%                                       A value of 0.1 would filter oscillatory behaviour with threshold less than 0.1v but not greater
%                                       Default: 0 - ie will take no effect on filter
%                                       
%__________________________________________________________________________
% PsPM 3.2
% (C) 2009-2017 Tobias Moser (University of Zurich)

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
elseif isfield(options, 'missing_epochs_filename') && ~ischar(options.missing_epochs_filename)
    warning('ID:invalid_input', 'Argument ''options.missing_epochs_filename'' must be char array.'); return;
end

% create filters
d = NaN(size(data));
range_filter = data < options.max & data > options.min;
slope_filter = true(size(data));
diff_data = diff(data);
slope_filter(2:end) = abs(diff_data*sr) < options.slope;

if (options.deflection_threshold ~= 0);

    slope_epochs = filter_to_epochs(slope_filter);
    for r = slope_epochs';
        if range(data(r(1):r(2))) < options.deflection_threshold;
            slope_filter(r(1):r(2)) = 1;
        end;
    end;

end

% combine filters
filt = range_filter & slope_filter;
d(filt) = data(filt);

% write epochs to mat if missing_epochs_filename option is present
if isfield(options, 'missing_epochs_filename')
    if length(find(filt == 0)) > 0
        epochs = filter_to_epochs(filt);
    else;
        epochs = [];
    end;
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
    epoch_off(end + 1) = length(data);
end

% starts on
if (epoch_on(1) > epoch_off(1))
    epoch_on = [ 1; epoch_on ];
end

epochs = [ epoch_on, epoch_off ];
end