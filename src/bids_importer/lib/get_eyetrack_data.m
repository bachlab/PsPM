function [sts, eye_data_cell] = get_eye_data(subject_id, session_id, task_name, physio_path)
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

%% Initialize the cell array and info variables

sts = -1;
eye_signals = get_eyes_list(physio_path);
if isempty(eye_signals); warning('No eye data found: %s', eye_json_filepath); sts = -1 ;end % ------ %



num_signals = length(eye_signals);
eye_data_cell = cell(num_signals, 1);

chan_names = cell(num_signals, 1);
file_paths = cell(num_signals, 1);

%% Process each eye channel
for i = 1:num_signals
    signal = eye_signals{i};
    
    % Construct filenames based on BIDS naming convention:
    % e.g., sub-CalinetWuerzburg01_ses-01_task-FearAcquisition_recording-eye1_physio.json
    eye_json_filename = sprintf('%s_ses-%s_task-%s_recording-%s_physio.json', subject_id, session_id, task_name, signal);
    eye_tsv_filename  = sprintf('%s_ses-%s_task-%s_recording-%s_physio.tsv', subject_id, session_id, task_name, signal);
    
    eye_json_filepath = fullfile(physio_path, eye_json_filename);
    eye_tsv_filepath  = fullfile(physio_path, eye_tsv_filename);
    
    % Save file path and channel name for info
    file_paths{i} = eye_tsv_filepath;
    chan_names{i} = signal;
    
    % Check if files exist
    if ~isfile(eye_json_filepath); warning('File not found: %s', eye_json_filepath); sts = -1 ;end
    if ~isfile(eye_tsv_filepath); warning('File not found: %s', eye_tsv_filepath); sts = -1 ; end
    
    % Read JSON metadata (assumed to be converted into a struct)
    eye_json = extract_json_as_struct(eye_json_filepath);
    
    % Read TSV data.
    headings = eye_json.Columns;  
    col_types = repmat({'double'}, 1, length(headings));
    
    % read_data_from_tsv is assumed to return a numeric matrix with dimensions [n_samples x n_columns]
    eye_data_table = read_data_from_tsv(eye_tsv_filepath, false, headings.', col_types);
    
    % Combine the JSON metadata with the TSV data.
    % I the futrure some kind of check maybe?
    eye_json.Columns = eye_data_table;
    
    % SamplingFrequency -> SamplingRate
    if isfield(eye_json, 'SamplingFrequency')
        eye_json.SamplingRate = eye_json.SamplingFrequency;
        eye_json = rmfield(eye_json, 'SamplingFrequency');
    end
    
    % Store the combined struct into the cell array
    eye_data_cell{i} = eye_json;
    eye_data_cell{i}.source.file = [{eye_json_filepath};{eye_tsv_filepath}];
    
end
sts = 1;
end