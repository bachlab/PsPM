function [sts, data, infos] = get_physio_eye_data(candidate_paths, subject_id, session_id, task_id, run_id)

sts = -1;
data = {};
infos = struct();
infos.source = struct();

%% Process eye data
[ests, eye_data_cell] = get_eyetrack_data( ...
    candidate_paths, ...
    subject_id, ...
    session_id, ...
    task_id, ...
    run_id ...
);

if ests < 1 || isempty(eye_data_cell)
    warning('No eye data imported.');
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
% Prefer the folder where the eye file actually is, then try siblings under ses-*
sf = eye_data_cell{1}.source.file;
if iscell(sf), sf = sf{1}; end

[events_tsv_filepath, events_json_filepath] = find_physioevents_pair( ...
    candidate_paths, ...
    task_id, ...
    run_id ...
);

if strlength(events_json_filepath) > 0 && strlength(events_tsv_filepath) > 0
    data_events = get_physio_events_data( ...
        char(events_json_filepath), ...
        char(events_tsv_filepath), ...
        false ...
    );

    if ~isempty(data_events)
        for i = 1:numel(data_events)
            data_events{i}.header.StartTime = startTimeRef;
        end
        data = [data; data_events];
    else
        warning('No events for physio eye data were imported.');
    end
else
    % keep as warning or make it silent, your call
    if isempty(task_id)
        warning('No physioevents found for %s (ses-%s).', subject_id, session_id);
    else
        warning('No physioevents found for %s (ses-%s, task-%s).', subject_id, session_id, task_id);
    end
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