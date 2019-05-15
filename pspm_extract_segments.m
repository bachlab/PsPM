function [sts, out] = pspm_extract_segments(varargin)
% pspm_extract_segments. Function in order to extract segments of a certain
% length after defined onsets and create summary statistics
% (mean, SD, SEM, % NaN) over these segments
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
%       [sts, segments] = pspm_extract_segments('manual', data_fn, chan, timing, options)
%       [sts, segments] = pspm_extract_segments('auto', glm, options)
%       [sts, segments] = pspm_extract_segments('auto', dcm, options)
%
%   ARGUMENTS:
%       mode:               Tells the function in which mode get the
%                           settings from. Either 'manual' or 'auto'.
%       glm:                Path to the glm file or a glm structure.
%       dcm:                Path to the dcm file or a dcm structure.
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
%           timeunit:       'seconds' (default), 'samples' or 'markers. In 'auto'
%                           mode the value will be ignored and taken from
%                           the glm model file or the dcm model file.
%           length:         Length of the segments in the 'timeunits'.
%                           If given the same length is taken for
%                           segments for glm structure. If not given lengths
%                           are take from the timing data. This argument is optional. If
%                           'timeunit' equals 'markers' then 'length' is
%                           expected to be in seconds.
%                           For dcm structures the option length will be
%                           ignored and length will be set from timing
%                           data.
%           plot:           If 1 mean values (solid) and standard error of
%                           the mean (dashed) will be ploted. Default is 0.
%           outputfile:     Define filename to store segments. If is equal
%                           to '', no file will be written. Default is 0.
%           overwrite:      Define if already existing files should be
%                           overwritten. Default ist 0.
%           marker_chan:    Mandatory if timeunit is 'markers'. For the
%                           function to find the appropriate timing of the
%                           specified marker ids. Must have the same format
%                           as data_fn.
%           nan_output:     This option defines whether the user wants to
%                           output the NaN ratios of the trials for each condition.
%                           If so,  we values can be printed on the screen
%                           (on MATLAB command window) or written to a created file.
%                           The field can be set to 'screen', 'File Output'or
%                           'none'. 'none' is the default value.
%__________________________________________________________________________
% PsPM 4.3
% (C) 2008-2018 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;
sts = -1;

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
            if ~ischar(data_fn)
                if (iscell(data_fn) && any(~cellfun(@ischar, data_fn))) ||~iscell(data_fn)
                    warning('ID:invalid_input', 'data_fn has to be a string or a cell array of strings.'); return;
                end
            elseif ~isnumeric(chan)
                if(iscell(chan) && any(~cellfun(@isnumeric, chan))) || ~iscell(chan)
                    warning('ID:invalid_input', 'chan has to be numeric or a cell array of numerics.'); return;
                end
            elseif strcmpi(class(data_fn), class(chan)) && (iscell(chan) && (numel(chan) ~= numel(data_fn)))
                warning('ID:invalid_input', 'data_fn and chan must correspond in number of elements.'); return;
            elseif strcmpi(class(data_fn), class(timing)) && (iscell(timing) && (numel(timing) ~= numel(data_fn)))
                warning('ID:invalid_input', 'data_fn and timing must correspond in number of elements.'); return;
            end;
            
            % fix format of data_fn and chan if necessary
            if ~iscell(data_fn)
                data_fn = {data_fn};
            end;
            if ~iscell(chan)
                chan = {chan};
            end;
            
            % set flag to indicate 'manual'
            manual_chosen =1;
            
        case 'auto'
            
            struct_file = varargin{2};
            %case distinction on the type of the glm argument
            %if it is a path we need to load the glm structure into
            %function
            if ~isstruct(struct_file)
                if ~ischar(struct_file) || ~exist(struct_file, 'file')
                    warning('ID:invalid_input', 'GLM file is not a string or does not exist.'); return;
                end;
                [~, model_strc, ~] = pspm_load1(struct_file, 'all');
            else
                model_strc = struct_file;
            end
            
            if nargin == 3
                options = varargin{3};
            else
                options = struct();
            end;
            
            data_fn = model_strc.input.datafile;
            n_file = numel(data_fn);
            timing = model_strc.input.timing;
            chan = repmat({model_strc.input.channel}, size(data_fn));
            
            if strcmpi(model_strc.modeltype,'glm')
                options.timeunit = model_strc.input.timeunits;
                if strcmpi(options.timeunit, 'markers')
                    if isfield(model_strc.input.options, 'marker_chan_num')
                        options.marker_chan = model_strc.input.options.marker_chan_num;
                    else
                        warning('ID:invalid_input', ['''markers'' defined as ', ...
                            'timeunit, but cannot load the corresponding ', ...
                            'marker channel information from the GLM input.']);
                    end;
                end;
            end;
            
            manual_chosen =0;
            
        otherwise
            warning('ID:invalid_input', 'Unknown mode specified.'); return;
    end;
else
    warning('ID:invalid_input', 'The function expects at least 2 parameters.'); return;
end;

if ~iscell(data_fn)
    data_fn = {data_fn};
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

% set default marker_chan, if it is a glm struct
if  (manual_chosen ==1) || strcmpi(model_strc.modeltype,'glm')
    if ~isfield(options, 'marker_chan')
        options.marker_chan = repmat({-1}, numel(data_fn),1);
    elseif ~iscell(options.marker_chan)
        options.marker_chan = repmat({options.marker_chan}, size(data_fn));
    end;
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

%set default ouput_nan
if ~isfield(options, 'nan_output')|| strcmpi(options.nan_output, 'none')
    options.nan_output = 'none';
elseif ~strcmpi( options.nan_output,'screen')
    [path, name, ext ]= fileparts(options.nan_output);
    if 7 ~= exist(path, 'dir')
        warning('ID:invalid_input', 'Path for nan_output does not exist'); return;
    end
end

% check mutual arguments (options)
if ~ismember(options.timeunit, {'seconds','samples', 'markers'})
    warning('ID:invalid_input', 'Invalid timeunit, use either ''markers'', ''seconds'' or ''samples'''); return;
elseif ~isnumeric(options.length)
    warning('ID:invalid_input', 'options.length is not numeric.'); return;
elseif ~isnumeric(options.plot) && ~islogical(options.plot)
    warning('ID:invalid_input', 'options.plot is not numeric.'); return;
elseif ~isempty(options.outputfile) && ~ischar(options.outputfile)
    warning('ID:invalid_input', 'options.outputfile has to be a string.'); return;
elseif ~isnumeric(options.overwrite) && ~islogical(options.overwrite)
    warning('ID:invalid_input', 'Options.overwrite has to be numeric or logical.'); return;
elseif ~isnumeric(options.dont_ask_overwrite) && ~islogical(options.dont_ask_overwrite)
    warning('ID:invalid_input', 'Options.dont_ask_overwrite has to be numeric or logical.'); return;
elseif strcmpi(options.timeunit, 'markers') && ~all(size(data_fn) == size(options.marker_chan))
    warning('ID:invalid_input', '''data_fn'' and ''options.marker_chan'' do not have the same size.'); return;
elseif (manual_chosen ==1) ||  strcmpi(model_strc.modeltype,'glm')
    if any(cellfun(@(x) ~strcmpi(x, 'marker') && ~isnumeric(x), options.marker_chan))
        warning('ID:invalid_input', 'Options.marker_chan has to be numeric or ''marker''.'); return;
    elseif strcmpi(options.timeunit, 'markers') ...
            && any(cellfun(@(x) isnumeric(x) && x <= 0, options.marker_chan))
        warning('ID:invalid_input', ['''markers'' specified as a timeunit but ', ...
            'no valid marker channel is defined.']); return;
    end;
end;

if manual_chosen == 1 || strcmpi(model_strc.modeltype, 'glm')
    n_sessions = numel(data_fn);
else
    n_sessions = numel(model_strc.input.scr);
end

% load timing
if manual_chosen == 1
    [~, multi]  = pspm_get_timing('onsets', timing, options.timeunit);
    % If the timeunit is markers, the multi struct holds for every session.
    % Thus we need as many replicas as there are sessions
    if strcmpi(options.timeunit, 'markers')
        temp = multi;
        clear multi;
        for k=1:n_sessions
            multi(k) = temp;
        end
    end
    input_data = {};
    sampling_rates = [];
    marker_data = {};
    for i=1:numel(data_fn)
        [sts, ~, data] = pspm_load_data(data_fn{i}, chan{i});
        assert(sts == 1);
        input_data{end + 1} = data{1}.data;
        sampling_rates(end + 1) = data{1}.header.sr;
        if strcmpi(options.timeunit, 'markers')
            [sts, ~, data] = pspm_load_data(data_fn{i}, options.marker_chan{i});
            assert(sts == 1);
            marker_data{end + 1} = data;
        end
    end
elseif strcmpi(model_strc.modeltype, 'glm')
    multi = model_strc.timing.multi;
    input_data = model_strc.input.data;
    sampling_rates = model_strc.input.sr;
    filtered_sr = model_strc.input.filter.down; 
else
    % want to map the informations of dcm into a multi
    cond_names = unique(model_strc.trlnames);

    if numel(cond_names) == numel(model_strc.trlnames)
        model_strc.trlnames(:) = {'all_cond'};
        cond_names(:) = {'all_cond'};
    end
    
    point=1;
    for i = 1:n_sessions
        nr_trials_in_sess = size(model_strc.input.trlstart{i},1);
        
        min_iti = min(model_strc.input.iti{i});
        min_trl_interval = min(model_strc.input.trlstop{i} - model_strc.input.trlstart{i});
        durations(1:nr_trials_in_sess) = min_iti + min_trl_interval;
        
        if(numel(cond_names)>1)
            multi(i).names = unique(model_strc.trlnames(point:point+nr_trials_in_sess-1))';
            % we define the segment_length as min(intertrial-interval)+
            % min(trialoffset - trialonset)
            for j=1: numel(cond_names)
                idx_start = point;
                idx_stop = point+nr_trials_in_sess-1;
                cond_name = cond_names{j};
                cond_idx = find(strcmpi(cond_name, multi(i).names));
                if isempty(cond_idx)
                    continue
                end
                idx_of_name = find(strcmpi(cond_name,model_strc.trlnames));
                idx_of_name = idx_of_name(idx_start <= idx_of_name);
                idx_of_name = idx_of_name(idx_stop >= idx_of_name)- point +1;
                multi(i).onsets{cond_idx}= model_strc.input.trlstart{i}(idx_of_name);
                multi(i).durations{cond_idx}= durations(1:numel(idx_of_name));
            end
        else
            multi(i).names = {'all_cond'};
            multi(i).onsets = model_strc.input.trlstart{i};
            multi(1).durations{1} = durations;
        end
        point= point+nr_trials_in_sess;
    end;
    input_data = model_strc.input.scr;
    sampling_rates = model_strc.input.sr;
    if numel(sampling_rates) == 1
        sampling_rates = repmat(sampling_rates, n_sessions, 1);
    end
end;


%% not all sessions have the same number of conditions
% create a new multi structure which contains all conditions and their
% timings. There are multiple cases: sessions with missing conditions and
% sessions which contain empty
% prepare timing variables
comb_onsets = {};
comb_names = {};
comb_durations = {};
comb_sessions = {};
comb_cond_nr = {};

% get all different conditions names in multi
if ~isempty(multi)
    for iSn = 1:n_sessions
        % nuber of names must always correspond with the number of onset
        % arrays for a specific session
        if numel(multi(iSn).names) ~=  numel(multi(iSn).onsets)
            str = sprintf('session %d: nr. of indicated conditions [through names] does not correspond with number of available onset-arrays',iSn);
            warning('ID:invalid_input', str);
            return;
        end
        for n = 1:numel(multi(iSn).names)
            multi_onsets_n = multi(iSn).onsets{n};
            length_m_o_n = max(size(multi_onsets_n));
            if ~isempty(multi_onsets_n)
                multi_duration_n = multi(iSn).durations{n};
                length_m_d_n = max(size(multi_duration_n));
            else
                multi_duration_n = [];
                length_m_d_n = 0;
            end
            
            % look for index
            name_idx = find(strcmpi(comb_names, multi(iSn).names(n)));
            if numel(name_idx) > 1
                warning(['Name was found multiple times, ', ...
                    'will take first occurence.']);
                name_idx = name_idx(1);
            elseif numel(name_idx) == 0
                % append
                name_idx = numel(comb_names) + 1;
            end
            % add new condition name to list
            if numel(comb_names) < name_idx
                comb_names{name_idx} = multi(iSn).names{n};
                comb_onsets{name_idx} = multi_onsets_n;
                comb_durations{name_idx} = multi_duration_n;
                comb_sessions{name_idx}(1:length_m_o_n) = iSn;
                comb_cond_nr{name_idx}(1:length_m_o_n) = name_idx;
            elseif numel(comb_names) >= name_idx && 0 < name_idx
                if isempty(comb_onsets{name_idx})
                    comb_onsets{name_idx} = multi_onsets_n;
                    comb_durations{name_idx}= multi_duration_n;
                    comb_sessions{name_idx}(1:length_m_o_n) = iSn;
                    comb_cond_nr{name_idx}(1:length_m_o_n) = name_idx;
                else
                    comb_onsets{name_idx}(end+1:end+length_m_o_n) = multi_onsets_n;
                    comb_durations{name_idx}(end+1:end+length_m_d_n)= multi_duration_n;
                    comb_sessions{name_idx}(end+1:end+length_m_o_n) = iSn;
                    comb_cond_nr{name_idx}(end+1:end+length_m_o_n) = name_idx;
                end
                
            end
        end
    end
end
% number of conditions
n_cond = numel(comb_names);
segments = cell(n_cond,1);

if options.plot
    fg = figure('Name', 'Condition mean per subject', 'Visible', 'off');
    ax = axes('NextPlot', 'add');
    set(fg, 'CurrentAxes', ax);
    
    % load colormap
    corder = get(fg, 'defaultAxesColorOrder');
    cl = length(corder);
    
    % legend labels
    legend_lb = cell(n_cond*3,1);
end;

%% This section gives each trial over all session a uniquie identifier.
all_sessions = cell2mat(cellfun(@(x)reshape(x, [min(size(x)), max(size(x))]),comb_sessions,'un', 0));
all_cond_nr =cell2mat(cellfun(@(x)reshape(x, [min(size(x)), max(size(x))]),comb_cond_nr,'un', 0));
all_onsets  = cell2mat(cellfun(@(x)reshape(x, [min(size(x)), max(size(x))]),comb_onsets,'un', 0));
all_dur = cell2mat(cellfun(@(x)reshape(x, [min(size(x)), max(size(x))]),comb_durations,'un', 0));
all_sess_ons =[all_onsets' , all_sessions'];
all_dur_cond = [all_dur', all_cond_nr'];
%all_sess_ons_cond = [all_onsets' , all_sessions', all_cond_nr'];
sorted_session = sortrows(all_sess_ons,[2 1]);

% find idx. the function throws a warning if a specific condition and a
% specific session contains multiple identical onsets
sorted_idx(1:size(all_cond_nr,2)) = 0;
for k = 1: size(all_cond_nr,2)
    a = all_sess_ons(k,:);
    b = find(all(a == sorted_session,2));
    nr_found = numel(b);
    if sorted_idx(k)~=0
        continue;
    elseif nr_found ~=1
        warning(sprintf('Condition nr. %d in session %d contains multiple identical onsets. The segment will hold identical trials.',a(2),all_cond_nr(k)));
        idx_found = all(a == all_sess_ons,2);
        sorted_idx(idx_found)= b;
    else
        sorted_idx(k)= b;
    end
    
end
all_sess_ons_cond_idx = [all_onsets' , all_sessions', all_cond_nr',sorted_idx'];
for i=1:n_cond
    segments{i}.trial_idx = all_sess_ons_cond_idx(all_sess_ons_cond_idx(:,3) == i, 4);
end

n_onsets_in_cond = {};
for c = 1:n_cond
    n_onsets_in_cond{c} = sum(all_cond_nr == c);
end

% TODO: Create three different versions of this function instead of branching all the time?
% IMO there are enough different data loading and processing logic that should separate these
% methods to different functions.
%% save data in segments
num_prev_conds = 0;
if manual_chosen == 1 || strcmpi(model_strc.modeltype, 'dcm')
    onsets = [];
    durations = [];
    for i = 1:n_sessions
        onsets = [onsets, multi(i).onsets];
        durations = [durations, multi(i).durations];
    end
else
    onsets = model_strc.timing.onsets;
    durations = model_strc.timing.durations;
end
for session_idx = 1:n_sessions
    sr = sampling_rates(session_idx);
    % load data
    session_data = input_data{session_idx};
    if manual_chosen == 1 && strcmpi(options.timeunit, 'markers')
        marker = marker_data{n};
    end
    num_conds_in_session = numel(multi(session_idx).names);
    for c = 1:num_conds_in_session
        cond_idx = find(strcmpi(comb_names, multi(session_idx).names{c}));
        all_onset_sessions_in_cond = all_sess_ons_cond_idx(all_sess_ons_cond_idx(:, 3) == cond_idx, 2);
        onset_write_indices_in_cond_and_session = find(all_onset_sessions_in_cond == session_idx);

        idx_to_timing = num_prev_conds + c;
        onsets_cond = onsets{idx_to_timing};
        durations_cond = durations{idx_to_timing};
        num_onsets = numel(onsets_cond);
        assert(numel(onset_write_indices_in_cond_and_session) == num_onsets);

        for onset_idx = 1:num_onsets
            % in case of glm, start is a signal index to filtered Y data.
            start = onsets_cond(onset_idx);
            
            if options.length <= 0
                try
                    segment_length = durations_cond(onset_idx);
                    if segment_length==0
                        warning('ID:invalid_input', 'Cannot determine onset duration. Durations is set to 0.'); return;
                    end
                catch
                    warning('ID:invalid_input', 'Cannot determine onset duration.'); return;
                end;
            else
                segment_length = options.length;
            end;

            % ensure start and segment_length have the 'sample' format to
            % access on data
            switch options.timeunit
                case 'seconds'
                    segment_length = segment_length*sr;
                    if manual_chosen == 1 || strcmpi(model_strc.modeltype, 'dcm')
                        % TODO: what happens if data is downsampled in DCM? Check DCM trlstart-stop variables
                        % to see if they refer to original or filtered data. We assume the former here.
                        start = start * sr;
                    else
                        start = start * sr / filtered_sr;
                    end
                case 'markers'
                    segment_length = segment_length*sr;
                    if manual_chosen == 1
                        start = marker(start)*sr;
                    else
                        assert(~strcmpi(model_strc.modeltype, 'dcm'));
                        start = start * sr / filtered_sr;
                    end
            end;
            
            start = max(1, round(start));
            stop = min(numel(session_data) + 1, start + round(segment_length));
            % % set stop
            % stop = start + segment_length;
            % 
            % % ensure start and stop have the correct format
            % start = max(1,round(start));
            % stop = min(numel(session_data), round(stop));
            
            if ~isfield(segments{cond_idx}, 'data')
                segments{cond_idx}.data = NaN((stop-start), n_onsets_in_cond{cond_idx});
            end;
            if (stop - start) > size(segments{cond_idx}.data, 1)
                last_row = size(segments{cond_idx}.data, 1);
                segments{cond_idx}.data(last_row + 1 : (stop - start), :) = NaN;
            end

            onset_write_idx = onset_write_indices_in_cond_and_session(onset_idx);
            segments{cond_idx}.data(1:(stop-start), onset_write_idx) = session_data(start:(stop-1));
        end;
    end;
    num_prev_conds = num_prev_conds + num_conds_in_session;
end;

%% create statistics for each condition
for c=1:n_cond
    m = segments{c}.data;
    segments{c}.name = comb_names{c};
    % create mean
    segments{c}.mean = nanmean(m,2);
    
    segments{c}.std = nanstd(m,0,2);
    segments{c}.sem = segments{c}.std./sqrt(n_onsets_in_cond{c});
    segments{c}.trial_nan_percent = sum(isnan(m))/size(m,1);
    segments{c}.total_nan_percent = sum(sum(isnan(m)))/numel(m);
    %   segments{c}.total_nan_percent = mean(segments{c}.trial_nan_percent);
    
    
    sr = sampling_rates(1);  % TODO: assuming sampling rates in all sessions are equal?
    segments{c}.t = linspace(sr^-1, numel(segments{c}.mean)/sr, numel(segments{c}.mean))';
    %% create plot per condition
    if options.plot
        p = plot(ax, segments{c}.t, segments{c}.mean, '-', ...
            segments{c}.t, segments{c}.mean + segments{c}.sem, '-', ...
            segments{c}.t, segments{c}.mean - segments{c}.sem, '-');
        % correct colors
        color = corder(mod(c,cl) + 1, :);
        set(p(1), 'LineWidth', 2, 'Color', color);
        set(p(2), 'Color', color);
        set(p(3), 'Color', color);
        
        legend_lb{(c-1)*3 + 1} = [comb_names{c} ' AVG'];
        legend_lb{(c-1)*3 + 2} = [comb_names{c} ' SEM+'];
        legend_lb{(c-1)*3 + 3} = [comb_names{c} ' SEM-'];
    end;
end;

%% nan_output
if ~strcmpi(options.nan_output,'none')
    %count number of trials
    trials_nr_per_cond = cellfun(@(x) size(x.trial_idx,1),segments,'un',0);
    trials_nr = cell2mat(trials_nr_per_cond);
    trials_nr_sum = sum(trials_nr);
    
    %create matix with values
    trials_nan(1:(trials_nr_sum+1),1:n_cond) = NaN;
    for i=1:n_cond
        %nan_idx_length = trials_nr(i);
        nan_idx_length = size(segments{i}.trial_idx,1);
        for j = 1:nan_idx_length
            nan_perc = segments{i}.trial_nan_percent(j);
            trials_nan(segments{i}.trial_idx(j),i) = nan_perc;
        end
        trials_nan(trials_nr_sum+1,i) = segments{i}.total_nan_percent;
    end
    
    %define names of rows in table
    r_names = strsplit(num2str(1:trials_nr_sum));
    r_names{end+1} = 'total';
    %valriable Names
    var_names = cellfun(@(x)regexprep( x, '[+]' , '_plus'), comb_names, 'un',0);
    var_names = cellfun(@(x)regexprep( x, '[-]' , '_minus'), var_names, 'un',0);
    var_names = cellfun(@(x)regexprep( x, '[^a-zA-Z0-9]' , '_'), var_names, 'un',0);
    %create table with the right format
    trials_nan_output = array2table(trials_nan,'VariableNames', var_names, 'RowNames', r_names');
    switch options.nan_output
        case 'screen'
            fprintf(['\nThe following tabel shows for each condition the NaN-ratio ',...
                'in the different trials.\nA NaN-value in the table indicates ',...
                'that a trial does not correspond to the condition.\n',...
                'The last value indicates the average Nan-ratio over all trials ',...
                'belonging to this condition.\n\n']);
            disp(trials_nan_output);
        case 'none'
        otherwise
            %print Nan-Value in file
            %expect the path to file in options.nan_output
            %find information about file
            [path, name, ext ]= fileparts(options.nan_output);
            
            %if the file already exists, we overwrite the file with the
            %data. Otherwise we create a new file and save the data
            %             new_file_base = sprintf('%s.csv', name);
            new_file_base = sprintf('%s.txt', name);
            output_file = fullfile(path,new_file_base);
            fprintf(['\nThe table in file (%s)shows for each condition the NaN-ratio ',...
                'in the different trials.\nA NaN-value in the table indicates ',...
                'that a trial does not correspond to the condition.\n',...
                'The last value indicates the average Nan-ratio over all trials ',...
                'belonging to this condition.\n\n'],new_file_base);
            writetable(trials_nan_output, output_file,'WriteRowNames', true ,'Delimiter', '\t');
            
            
    end
end
%% set output and save segments into file
out.segments = segments;

if ~isempty(options.outputfile)
    % ensure correct file suffix
    [pt, fn, ~] = fileparts(options.outputfile);
    outfile = [pt filesep fn '.mat'];
    write_ok = 0;
    if exist(outfile, 'file')
        if options.overwrite
            write_ok = 1;
        elseif ~options.dont_ask_overwrite
            button = questdlg(sprintf('File (%s) already exists. Replace file?', ...
                outfile), 'Replace file?', 'Yes', 'No', 'No');
            
            write_ok = strcmpi(button, 'Yes');
        end;
    else
        write_ok = 1;
    end;
    
    if write_ok
        save(outfile, 'segments');
        out.outputfile = outfile;
    end;
end;

if options.plot
    % show plot
    set(fg, 'Visible', 'on');
    legend(legend_lb);
end;

sts = 1;
