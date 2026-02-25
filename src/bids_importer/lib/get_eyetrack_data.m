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
eye_files = find_eye_files( ...
    candidate_paths, ...
    task_id, ...
    run_id ...
);

% enfore cell
if isstring(eye_files)
    eye_files = cellstr(eye_files);
end

% If eye_files is a char (single path):
if ischar(eye_files)
    eye_files = {eye_files};
end

%% Initialize the cell array and info variables

sts = -1;
eye_signals = get_eyes_list(eye_files);
eye_data_cell = {};

if isempty(eye_signals)
    warning('No eye data found for subject %s session %s', subject_id,session_id); 
else % ------ %

num_signals = length(eye_signals);
eye_data_cell = cell(num_signals, 1);
chan_names = cell(num_signals, 1);

%% Process each eye channel
for i = 1:num_signals
    signal = eye_signals{i};
    eye_tsv_filepath = eye_files{i};
    eye_json_filepath = regexprep(eye_tsv_filepath, '\.tsv\.gz$', '.json');

    % Check if files exist
    if ~isfile(eye_json_filepath); warning('File not found: %s', eye_json_filepath); sts = -1 ;end
    if ~isfile(eye_tsv_filepath); warning('File not found: %s', eye_tsv_filepath); sts = -1 ; end
    
    fprintf('%s:\t%s\n', signal, eye_tsv_filepath);

    % Read JSON metadata (assumed to be converted into a struct)
    eye_json = extract_json_as_struct(eye_json_filepath);
    
    % Read TSV data.
    headings = eye_json.Columns;  
    col_types = repmat({'double'}, 1, length(headings));
    
    % read_data_from_tsv is assumed to return a numeric matrix with dimensions [n_samples x n_columns]
    eye_data_table = read_data_from_tsv( ...
        eye_tsv_filepath, ...
        false, ...
        headings.', ...
        col_types ...
    );
    
    % Combine the JSON metadata with the TSV data.
    % I the futrure some kind of check maybe?
    eye_json.Columns = eye_data_table;
    
    % Store the combined struct into the cell array
    eye_data_cell{i} = eye_json;
    eye_data_cell{i}.source.file = [{eye_json_filepath}, {eye_tsv_filepath}];
    
end
    sts = 1;
end

end