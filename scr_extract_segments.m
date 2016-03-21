function [sts, segments] = scr_extract_segments(data_fn, chan, timing, options)
% Function in order to extract segments of a certain length after defined
% onsets and create mean over segments in order to compare data within a
% sigle recording.
%
%   FORMAT:
%       [sts, segments] = scr_extract_segments(data_fn, chan, timing, options)
%   ARGUMENTS:
%       data_fn:            Path to the data file which contains the
%                           recorded data from which the segments should be
%                           taken.
%       chan:               Channel in the data file which should be taken
%                           for segment extraction.
%       timing:             Either a cell containing the timing settings or
%                           a string pointing to the timing file.
%       options:
%           timeunit:      'seconds' (default) or 'samples'
%           length:         Length of the segments in the 'timeuits'. 
%                           If given always the same length is taken for 
%                           segments. If not given lengths are take from 
%                           the timing data. This argument is optional.
%
%__________________________________________________________________________
% PsPM 3.1
% (C) 2008-2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sts = -1;
segments = {};

if ~exist('options', 'var')
    options = struct();
end;

if ~isfield('timeunit', options)
    options.timeunit = 'seconds';
else
    options.timeunit = lower(options.timeunit);
end;

if ~isfield('length', options)
    options.length = -1;
end;

% check for valid input
if ~ischar(data_fn) && (iscell(data_fn) && any(~cellfun(@ischar, data_fn)))
    warning('ID:invalid_input', 'data_fn has to be a string or a cell array of strings.'); return;
elseif ~isnumeric(chan) && (iscell(chan) && any(~cellfun(@isnumeric), chan))
    warning('ID:invalid_input', 'chan has to be numeric or a cell array of numerics.'); return;
elseif strcmpi(class(data_fn), class(chan)) && (iscell(chan) && (numel(chan) ~= numel(data_fn)))
    warning('ID:invalid_input', 'data_fn and chan must correspond in number of elements.'); return;
elseif strcmpi(class(data_fn), class(timing)) && (iscell(timing) && (numel(timing) ~= numel(data_fn)))
    warning('ID:invalid_input', 'data_fn and timing must correspond in number of elements.'); return;
elseif ~ismember(options.timeunit, {'seconds','samples'})
    warning('ID:invalid_input', 'Invalid timeunit, use either ''seconds'' or ''samples'''); return;
elseif ~isnumeric(options.length)
    warning('ID:invalid_input', 's_length is not numeric.'); return;
end;

if ~iscell(data_fn)
    data_fn = {data_fn};
end;

if ~iscell(chan)
    chan = {chan};
end;

% load timing
[~, multi]  = scr_get_timing('onsets', timing, options.timeunit);

% start to extract segments
segments = cell(numel(data_fn),1);
for n = 1:numel(data_fn)
    % load data
    [~, ~, data] = scr_load_data(data_fn{n}, chan{n});
    
    segments{n} = cell(numel(multi(n).names));
    for c = 1:numel(multi(n).names)
        for o = 1:numel(multi(n).onsets{c})
            start = multi(n).onsets{c}(o);
            if options.length == -1
                try
                    stop = start + multi(n).durations{c}(o);
                catch
                    warning('ID:invalid_input', 'Cannot determine onset duration.'); return;
                end;
            else
                stop = start + options.length;
            end;

            switch options.timeunit
                case 'seconds'
                    start = data{1}.header.sr*start;
                    stop = data{1}.header.sr*stop;
            end;
            segments{n}{c,o}.data = data{1}.data(start:stop);
            segments{n}{c,o}.mean = mean(data{1}.data(start:stop));
            segments{n}{c,o}.var = var(data{1}.data(start:stop));
        end;
    end;
end;

