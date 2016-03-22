function [sts, segments] = scr_extract_segments(varargin)
% Function in order to extract segments of a certain length after defined
% onsets and create mean over segments in order to compare data within a
% sigle recording.
%
% The function supports either manual setting of data files, channels,
% timing and timeunits or automatic extraction from a glm model file.
%
% The segments variable returned will be a nx1 cell where n corresponds to
% the number of sessions. Each element contains a kxl cell where k
% corresponds to the number of conditions and l to the number of onsets/events.
% The elements of the kxl cell will contain a struct with fields data, mean
% and var.
%
%   FORMAT:
%       [sts, segments] = scr_extract_segments('manual', data_fn, chan, timing, options)
%       [sts, segments] = scr_extract_segments('auto', glm, options)
%
%   ARGUMENTS:
%       mode:               Tells the function in which mode get the
%                           settings from. Either 'manual' or 'auto'.
%       glm:                Path to the glm file. 
%       data_fn:            Path or cell of paths to data files from which
%                           the segments should be extracted.
%       chan:               Channel number or cell of channel numbers which
%                           defines which channel should be taken to
%                           extract the segments. Chan should correspond to
%                           data_fn and should have the same length. If
%                           data_fn is a cell and chan is a single number,
%                           the number will be taken for all files.
%       timing:             Either a cell containing the timing settings or
%                           a string pointing to the timing file.
%       options:
%           timeunit:      'seconds' (default) or 'samples'. In 'auto' mode
%                           the value will be ignored and take from the glm
%                           model file.
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

if nargin >= 2
    switch varargin{1}
        case 'manual'
            if nargin < 4
                warning('ID:invalid_input', 'Mode ''auto'' expects at least 4 arguments.'); return;
            end;
            
            data_fn = varargin{2};
            chan = varargin{3};
            timing = varargin{4};
            
            if nargin == 5
                options = varargin{5};
            else
                options = struct();
            end;
                                                
            % expand chan if necessary
            if iscell(data_fn) && isnumeric(chan) ...
                    && numel(chan) == 1
                chan = repmat({chan}, size(data_fn));
            end;
            
            % check if specific arguments are correct
            if ~ischar(data_fn) && (iscell(data_fn) && any(~cellfun(@ischar, data_fn)))
                warning('ID:invalid_input', 'data_fn has to be a string or a cell array of strings.'); return;
            elseif ~isnumeric(chan) && (iscell(chan) && any(~cellfun(@isnumeric, chan)))
                warning('ID:invalid_input', 'chan has to be numeric or a cell array of numerics.'); return;
            elseif ~strcmpi(class(data_fn), class(chan)) || (iscell(chan) && (numel(chan) ~= numel(data_fn)))
                warning('ID:invalid_input', 'data_fn and chan must correspond in number of elements.'); return;
            elseif ~strcmpi(class(data_fn), class(timing)) || (iscell(timing) && (numel(timing) ~= numel(data_fn)))
                warning('ID:invalid_input', 'data_fn and timing must correspond in number of elements.'); return;
            end;
            
            % fix format of data_fn and chan if necessary
            if ~iscell(data_fn)
                data_fn = {data_fn};
            end;
            if ~iscell(chan)
                chan = {chan};
            end;

        case 'auto'
            
            glm_file = varargin{2};
            if ~ischar(glm_file) || ~exist(glm_file, 'file')
                warning('ID:invalid_input', 'GLM file is not a string or does not exist.'); return;
            end;
            
            [~, glm, ~] = scr_load1(glm_file, 'all');
                        
            if nargin == 3
                options = varargin{3};
            else
                options = struct();
            end;
                        
            data_fn = glm.input.datafile;
            timing = glm.input.timing;
            chan = repmat({glm.input.channel}, size(data_fn));
            options.timeunit = glm.input.timeunits;
            
        otherwise
                warning('ID:invalid_input', 'Unknown mode specified.'); return;
    end;
else
    warning('ID:invalid_input', 'The function expects at least 2 parameters.'); return;
end;

if ~isstruct(options)
    warning('ID:invalid_input', 'Options must be a struct.'); return;
end;

% set default timeunit
if ~isfield('timeunit', options)
    options.timeunit = 'seconds';
else
    options.timeunit = lower(options.timeunit);
end;

% set default length
if ~isfield('length', options)
    options.length = -1;
end;

% check mutual arguments (options)   
if ~ismember(options.timeunit, {'seconds','samples'})
    warning('ID:invalid_input', 'Invalid timeunit, use either ''seconds'' or ''samples'''); return;
elseif ~isnumeric(options.length)
    warning('ID:invalid_input', 'options.length is not numeric.'); return;
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
            segments{n}{c,o}.mean = nanmean(data{1}.data(start:stop));
            segments{n}{c,o}.var = nanvar(data{1}.data(start:stop));
        end;
    end;
end;

sts = 1;