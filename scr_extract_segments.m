function [sts, out] = scr_extract_segments(varargin)
% Function in order to extract segments of a certain length after defined
% onsets and create mean over segments in order to compare data within a
% sigle recording.
%
% The function supports either manual setting of data files, channels,
% timing and timeunits or automatic extraction from a glm model file.
%
% The segments variable returned will be a cx1 cell where c corresponds to
% the number of conditions. Each element contains a struct with 
% fields data, mean, std and sem (std of the mean).
% The field data is a nxo*s vector where n is number of data points and o*s
% corresponds to the onsets multiplied by the sessions.
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
%                           the segments should be extracted. Each file
%                           will be treated as session. Onset values are
%                           averaged through conditions and sessions.
%       chan:               Channel number or cell of channel numbers which
%                           defines which channel should be taken to
%                           extract the segments. Chan should correspond to
%                           data_fn and should have the same length. If
%                           data_fn is a cell and chan is a single number,
%                           the number will be taken for all files.
%       timing:             Either a cell containing the timing settings or
%                           a string pointing to the timing file.
%       options:
%           timeunit:       'seconds' (default) or 'samples'. In 'auto' 
%                           mode the value will be ignored and take from 
%                           the glm model file.
%           length:         Length of the segments in the 'timeunits'. 
%                           If given always the same length is taken for 
%                           segments. If not given lengths are take from 
%                           the timing data. This argument is optional.
%           plot:           If 1 mean values (solid) and standard error of
%                           the mean (dashed) will be ploted. Default is 0.
%           outputfile:     Define filename to store segments. If is equal
%                           to '', no file will be written. Default is 0.
%           overwrite:      Define if already existing files should be
%                           overwritten. Default ist 0.
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
out = struct();

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
if ~isfield(options, 'timeunit')
    options.timeunit = 'seconds';
else
    options.timeunit = lower(options.timeunit);
end;

% set default length
if ~isfield(options, 'length')
    options.length = -1;
end;

% default plot
if ~isfield(options, 'plot')
    options.plot = 0;
end;

% outputfile
if ~isfield(options, 'outputfile')
    options.outputfile = '';
end;

% overwrite
if ~isfield(options, 'overwrite')
    options.overwrite = 0;
end;

% dont_ask_overwrite
if ~isfield(options, 'dont_ask_overwrite')
    options.dont_ask_overwrite = 0;
end;

% check mutual arguments (options)   
if ~ismember(options.timeunit, {'seconds','samples'})
    warning('ID:invalid_input', 'Invalid timeunit, use either ''seconds'' or ''samples'''); return;
elseif ~isnumeric(options.length)
    warning('ID:invalid_input', 'options.length is not numeric.'); return;
elseif ~isnumeric(options.plot)
    warning('ID:invalid_input', 'options.plot is not numeric.'); return;
elseif ~isempty(options.outputfile) && ~ischar(options.outputfile)
    warning('ID:invalid_input', 'options.outputfile has to be a string.'); return;
elseif ~isnumeric(options.overwrite) && ~islogical(options.overwrite)
    warning('ID:invalid_input', 'Options.overwrite has to be numeric or logical.'); return;
elseif ~isnumeric(options.dont_ask_overwrite) && ~islogical(options.dont_ask_overwrite)
    warning('ID:invalid_input', 'Options.dont_ask_overwrite has to be numeric or logical.'); return;
end;

% load timing
[~, multi]  = scr_get_timing('onsets', timing, options.timeunit);

% set size of segments according to first entry of timing
n_sessions = numel(data_fn);
n_cond = numel(multi(1).names);
n_onsets = numel(multi(1).onsets{1});
segments = cell(n_cond,1);

% load data
for n = 1:n_sessions
    [~, ~, data{n}] = scr_load_data(data_fn{n}, chan{n});
end;

if options.plot
    fh = figure('Name', 'Condition mean per subject');
    ax = axes(fh, 'NextPlot', 'add');
end;

for c = 1:n_cond
    for o = 1:n_onsets
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
                start = data{n}{1}.header.sr*start;
                stop = data{n}{1}.header.sr*stop;
        end;
        
        if ~isfield(segments{c}, 'data')
            segments{c}.data = NaN((stop-start), n_onsets*n_sessions);
        end;
        
        for n = 1:n_sessions
            segments{c}.data(1:(stop-start), (o+(n-1)*n_onsets)) = data{n}{1}.data(start:(stop-1));
        end;
    end;
    % create mean
    m = segments{c}.data;
    segments{c}.mean = mean(m,2);
    segments{c}.std = std(m,0,2);
    segments{c}.sem = segments{c}.std./sqrt(n_onsets*n_sessions);
    
    sr = data{1}{1}.header.sr;
    segments{c}.t = linspace(sr^-1, numel(segments{c}.mean)/sr, numel(segments{c}.mean))';
    
    if options.plot
        p = plot(ax, segments{c}.t, segments{c}.mean, '-', ...
            segments{c}.t, segments{c}.mean + segments{c}.sem, '-', ...
            segments{c}.t, segments{c}.mean - segments{c}.sem, '-');
        % correct colors
        set(p(1), 'LineWidth', 2);
        set(p(2), 'Color', get(p(1), 'Color'));
        set(p(3), 'Color', get(p(1), 'Color'));
    end;
end;

out.segments = segments;

if ~isempty(options.outputfile)
    write_ok = 0;
    if exist(options.outputfile, 'file')
        if options.overwrite 
            write_ok = 1;
        elseif ~options.dont_ask_overwrite
            button = questdlg(sprintf('File (%s) already exists. Replace file?', ...
                options.outputfile), 'Replace file?', 'Yes', 'No', 'No');
            
            write_ok = strcmpi(button, 'Yes');
        end;
    else
        write_ok = 1;
    end;
    
    if write_ok
        save(options.outputfile, 'segments');
        out.outputfile = options.outputfile;
    end;
end;

sts = 1;