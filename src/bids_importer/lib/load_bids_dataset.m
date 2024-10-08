function dataset = load_bids_dataset(dataset_source)

dataset = struct();
% dataset_description_filepath = fullfile(dataset_source, 'dataset_description.json');
% dataset.dataset_description = extract_json_as_struct(dataset_description_filepath);

[participants_data, participants_data_headings] = read_participants_data(dataset_source);
dataset.participant_information = participants_data_headings;
dataset.data = struct();

% ------------ For given subject ------------
[~, sub_key] = fileparts(dataset_source);  % Extract the folder name (sub-003)
sub_key = strrep(sub_key, '-', '_');

dataset.data.(sub_key) = struct();

subject_id = sub_key(end-2:end);

sub_path = dataset_source;
subject_dir = dir(sub_path);

% Get cogent data
dataset.data.(sub_key).subject_info = get_subject_data(participants_data, participants_data_headings, subject_id);

% ------------ For each session ------------
for j = 1:length(subject_dir)
    if startsWith(subject_dir(j).name, 'ses-') && subject_dir(j).isdir % For each 'ses-' directory
        ses_dir_name = subject_dir(j).name;
        ses_key = strrep(ses_dir_name,'-','_');
        % disp(ses_key);
        dataset.data.(sub_key).(ses_key) = struct();
        
        session_id = subject_dir(j).name(5:end);
        
        ses_path = fullfile(sub_path, subject_dir(j).name, 'beh');
        
        task_name = 'DelayFearConditioning';
        
        
        % ------------ eyetrack ------------
        eyes_list = get_eyes_list(ses_path);
        
        eye_filename_prefix = sprintf('sub-%s_ses-%s_task-%s_recording-', subject_id, session_id, task_name);
        
        events_json_filename = sprintf('sub-%s_ses-%s_task-%s_events.json', subject_id, session_id, task_name);
        events_json_filepath = fullfile(ses_path, events_json_filename);
        
        events_tsv_filename = sprintf('sub-%s_ses-%s_task-%s_events.tsv', subject_id, session_id, task_name);
        events_tsv_filepath = fullfile(ses_path, events_tsv_filename);
        
        beh_json_filename = sprintf('sub-%s_ses-%s_task-%s_beh.json', subject_id, session_id, task_name);
        beh_json_filepath = fullfile(ses_path, beh_json_filename);
        
        
        dataset.data.(sub_key).(ses_key).eyetrack = struct();
        % eyetrack.data
        [eyetrack_data, data_channels, recoding_duration] = get_eyetrack_data( ...
            eyes_list, eye_filename_prefix, ...
            ses_path, events_json_filepath, events_tsv_filepath ...
            );
        dataset.data.(sub_key).(ses_key).eyetrack.data = eyetrack_data;
        
        % eyetrack.info
        dataset.data.(sub_key).(ses_key).eyetrack.info = get_eyetrack_info(eyes_list, eye_filename_prefix, data_channels, ses_path, beh_json_filepath, recoding_duration);
    end
end
end
