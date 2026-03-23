function [sts, eye_data_cell] = get_eyetrack_data(candidate_paths, subject_id, session_id, task_id, run_id)
% get_eye_data Extracts eye-tracking data for a given subject, session, and task.
%
% This function returns a 2x1 cell array where each cell contains a struct
% with the following fields:
%   - header: structure containing metadata (e.g., channel type, sampling rate, units)
%   - Columns: numeric data read from the corresponding TSV file.
%
% Expected file naming:
%   <subject_id>_ses-<session_id>_task-<task_name>_recording-eye1_physio.json
%   <subject_id>_ses-<session_id>_task-<task_name>_recording-eye1_physio.tsv
%   <subject_id>_ses-<session_id>_task-<task_name>_recording-eye2_physio.json
%   <subject_id>_ses-<session_id>_task-<task_name>_recording-eye2_physio.tsv
%
% Example:
%   [eye_data, dur, info] = get_eye_data('sub-CalinetWuerzburg01','01','FearAcquisition', '/path/to/physio');

%% Find all 'tsv.gz' files in session directory
    eye_files = find_eye_files(candidate_paths, task_id, run_id);

    if isstring(eye_files)
        eye_files = cellstr(eye_files);
    end
    if ischar(eye_files)
        eye_files = {eye_files};
    end

    sts = -1;
    eye_data_cell = {};

    eye_signals = get_eyes_list(eye_files);

    if isempty(eye_signals)
        return
    end

    num_signals = numel(eye_signals);
    eye_data_cell = cell(num_signals, 1);

    for i = 1:num_signals
        signal = eye_signals{i};

        % Find the matching TSV for this eye signal
        match_idx = find(contains(eye_files, ['recording-' signal '_']), 1);

        if isempty(match_idx)
            warning('No TSV file found for eye signal %s', signal);
            continue
        end

        eye_tsv_filepath = eye_files{match_idx};
        eye_json_filepath = regexprep(eye_tsv_filepath, '\.tsv(\.gz)?$', '.json');

        if ~isfile(eye_json_filepath)
            warning('File not found: %s', eye_json_filepath);
            continue
        end
        if ~isfile(eye_tsv_filepath)
            warning('File not found: %s', eye_tsv_filepath);
            continue
        end

        fprintf('%s:\t%s\n', signal, eye_tsv_filepath);

        % Read metadata
        eye_meta = extract_json_as_struct(eye_json_filepath);

        % Read samples
        headings = eye_meta.Columns;
        col_types = repmat({'double'}, 1, numel(headings));

        eye_table = read_data_from_tsv( ...
            eye_tsv_filepath, ...
            false, ...
            headings.', ...
            col_types ...
        );

        % Store metadata + table explicitly
        entry = struct();
        entry.meta = eye_meta;
        entry.table = eye_table;
        entry.signal = signal;
        entry.source = struct( ...
            'json_file', eye_json_filepath, ...
            'tsv_file',  eye_tsv_filepath ...
        );

        eye_data_cell{i} = entry;
    end

    % remove empty cells if any entries were skipped
    eye_data_cell = eye_data_cell(~cellfun('isempty', eye_data_cell));

    if ~isempty(eye_data_cell)
        sts = 1;
    end
end