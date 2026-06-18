function [sts, data, infos] = get_physio_eye_data(candidate_paths, subject_id, session_id, task_id, run_id)

sts = -1;
data = {};
infos = struct();
infos.source = struct();

%% Process eye data
[ests, eye_data_cell] = get_eyetrack_data( ...
    candidate_paths, ...
    task_id, ...
    run_id ...
);

if ests < 1 || isempty(eye_data_cell)
    sts = -1;
    return
end

num_eyes = length(eye_data_cell);

%% Build eye channels
eye_channels = build_pspm_eye_channels(eye_data_cell);
data = eye_channels;

% Determine a StartTime reference for events
if ~isempty(data) && isfield(data{1}.header, 'StartTime')
    startTimeRef = data{1}.header.StartTime;
else
    startTimeRef = 0;
    for i = 1:numel(data)
        data{i}.header.StartTime = 0;
    end
end

%% Physioevents search dirs
[events_tsv_filepath, events_json_filepath] = find_physioevents_pair( ...
    candidate_paths, ...
    task_id, ...
    run_id ...
);

if strlength(events_json_filepath) > 0 && strlength(events_tsv_filepath) > 0

    % read physioevents.tsv.gz
    fprintf('PEVs:\t%s\n', events_tsv_filepath);
    data_events = get_physio_events_data( ...
        events_json_filepath, ...
        events_tsv_filepath, ...
        false ...
    );

    if ~isempty(data_events)
        for i = 1:numel(data_events)
            data_events{i}.header.StartTime = startTimeRef;
        end
        data = [data, data_events.'];
    end
else
    parts = {subject_id};
    
    if ~isempty(session_id)
        parts{end+1} = sprintf('ses-%s', session_id);
    end
    
    if ~isempty(task_id)
        parts{end+1} = sprintf('task-%s', task_id);
    end
    
    if exist('run_id','var') && ~isempty(run_id)
        parts{end+1} = sprintf('run-%s', run_id);
    end
    
    msg = strjoin(parts, ', ');
    
    warning('No physioevents found for %s.', msg);
end

%% Build infos.source.file
file_paths = {};

for i = 1:numel(eye_data_cell)
    if isfield(eye_data_cell{i}, 'source') && isfield(eye_data_cell{i}.source, 'file')
        sf = eye_data_cell{i}.source.file;
        if iscell(sf)
            for k = 1:numel(sf)
                file_paths{end+1,1} = char(sf{k}); %#ok<AGROW>
            end
        else
            file_paths{end+1,1} = char(sf); %#ok<AGROW>
        end
    end
end

if strlength(events_json_filepath) > 0
    file_paths{end+1,1} = char(events_json_filepath);
    file_paths{end+1,1} = char(events_tsv_filepath);
end

infos.source.file = file_paths;

% add eyesObserved
if num_eyes == 2
    infos.source.eyesObserved = 'lr'; 
elseif num_eyes == 1  
    infos.source.eyesObserved = data{1}.header.chantype(end); 
end

infos.source.best_eye = eye_with_smaller_nan_ratio(data, infos.source.eyesObserved);
infos.source.type = 'BIDS (json/tsv)' ;

sts = 1;
end


function data = get_physio_events_data(events_json_filepath, events_tsv_filepath, noColumnField)
%GET_PHYSIO_EVENTS_DATA Read BIDS physio/events data and build binary PsPM channels.
%
% Reads events metadata from JSON and sample/event rows from TSV/TSV.GZ.
% Creates binary channels for:
%   - blink
%   - saccade
%   - fixation
%
% Output:
%   data{s,1}.data            binary vector
%   data{s,1}.header.chantype e.g. 'blink_c'
%   data{s,1}.header.units    event label
%   data{s,1}.header.sr       sampling rate
%   data{s,1}.header.StartTime

    data = {};
    sr = 1;                % default fallback
    has_headings = true;
    col_types = {'double', 'double', 'char', 'char', 'char'}; % should 4 and 5 not be double?

    % Read JSON metadata
    event_json = extract_json_as_struct(events_json_filepath);

    if noColumnField 
        headings = fieldnames(event_json).';
    elseif isfield(event_json, 'Columns')
        headings = event_json.Columns;
    else
        headings = [];
    end

    % Read TSV / TSV.GZ
    marker_tsv_data_table = read_data_from_tsv( ...
        events_tsv_filepath, ...
        false, ... % should be true?! maybe this is the reasone the first line is imported?
        headings.', ...
        col_types ...
    );

    if ~istable(marker_tsv_data_table)
        warning('Could not read physio events table from %s', events_tsv_filepath);
        data = -1;
        return
    end

    required_vars = {'onset', 'duration'};
    if ~all(ismember(required_vars, marker_tsv_data_table.Properties.VariableNames))
        warning('Physio events table is missing required columns in %s', events_tsv_filepath);
        data = -1;
        return
    end
    
    has_event_type = ismember('event_type', marker_tsv_data_table.Properties.VariableNames);
    has_trial_type = ismember('trial_type', marker_tsv_data_table.Properties.VariableNames);
    
    if ~has_event_type && ~has_trial_type
        warning('Physio events table must contain either "event_type" or "trial_type" in %s', events_tsv_filepath);
        data = -1;
        return
    end
    
    if has_event_type
        event_type = string(marker_tsv_data_table.event_type); % char?
    else
        event_type = string(marker_tsv_data_table.trial_type); % char?
    end

    if ~ismember('message', marker_tsv_data_table.Properties.VariableNames)
        marker_tsv_data_table.message = repmat({''}, height(marker_tsv_data_table), 1);
    end

    % Checks if it is a proper physio eye event data
    if ~any(ismember(marker_tsv_data_table.Properties.VariableNames, {'blink', 'message'})) ...
            && ~any(strcmp(marker_tsv_data_table.event_type, 'blink')) ...
            && ~any(strcmp(marker_tsv_data_table.event_type, 'saccade')) ...
            && ~any(strcmp(marker_tsv_data_table.event_type, 'fixation'))
        warning('No physio events found in %s', events_tsv_filepath);
        data = -1;
        return
    end

    % Try to recover sampling rate from RECCFG message
    indices_reccfg = find(contains(string(marker_tsv_data_table.message), 'RECCFG'), 1);

    if ~isempty(indices_reccfg)
        reccfg = split(string(marker_tsv_data_table.message(indices_reccfg)));
        if numel(reccfg) >= 3
            sr_candidate = str2double(reccfg{3});
            if ~isnan(sr_candidate) && sr_candidate > 0
                sr = sr_candidate;
            end
        end
    elseif isfield(event_json, 'SamplingFrequency')
        sr_candidate = event_json.SamplingFrequency; %
        if isnumeric(sr_candidate) && isscalar(sr_candidate) && sr_candidate > 0
            sr = sr_candidate;
        end
    end

    % Remove header/config rows if present
    idx_header = strcmp(event_type, 'n/a') & ...
                 ~strcmp(string(marker_tsv_data_table.message), 'CS');
    
    idx_data = ~idx_header;
    
    onsets = marker_tsv_data_table.onset(idx_data);
    duration = marker_tsv_data_table.duration(idx_data);
    event_type = event_type(idx_data);

    if isempty(onsets)
        warning('No usable physio events found in %s', events_tsv_filepath);
        data = -1;
        return
    end

    % Shift first usable event to zero
    onsets = onsets - onsets(1);

    signal_names = {'blink', 'saccade', 'fixation'};
    channel_names = {'blink_c', 'saccade_c', 'fixation_c'};

    % Determine output length in samples
    end_times = onsets + duration;
    n_samples = max(1, ceil(max(end_times) * sr));

    for s = 1:numel(signal_names)
        idx_signal = strcmp(event_type, signal_names{s});

        data_signal = zeros(n_samples, 1);

        if any(idx_signal)
            starts_sec = onsets(idx_signal);
            ends_sec   = onsets(idx_signal) + duration(idx_signal);

            starts_idx = max(1, floor(starts_sec * sr) + 1);
            ends_idx   = min(n_samples, ceil(ends_sec * sr));

            for i = 1:numel(starts_idx)
                if ends_idx(i) >= starts_idx(i)
                    data_signal(starts_idx(i):ends_idx(i)) = 1;
                end
            end
        end

        data{s,1}.data = data_signal;
        data{s,1}.header = struct();
        data{s,1}.header.chantype = channel_names{s};
        data{s,1}.header.units = signal_names{s};
        data{s,1}.header.sr = sr;
        data{s,1}.header.StartTime = 0;
    end
end


% adapted from in pspm_get_viewpoint and pspm_get_smi
function best_eye = eye_with_smaller_nan_ratio(data, eyes_observed)
    
    if isscalar(eyes_observed)
      best_eye = lower(eyes_observed);
    else

      eye_L_max_nan_ratio = 0;
      eye_R_max_nan_ratio = 0;

      n = numel(data);

      for i = 1:n

          chantype = data{i}.header.chantype;
          eye_side = lower(chantype(end));

          nan_count = sum(isnan(data{i}.data));

          if eye_side == 'l'
              eye_L_max_nan_ratio = max(eye_L_max_nan_ratio, nan_count);

          elseif eye_side == 'r'
              eye_R_max_nan_ratio = max(eye_R_max_nan_ratio, nan_count);
          end
      end

      if eye_L_max_nan_ratio > eye_R_max_nan_ratio
        best_eye = 'r'; 
      else
        best_eye = 'l'; % if equal set 'l'
      end
    end
end