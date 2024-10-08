function sub_data = load_sub_data(dataset_source, sub_dir_name)
% dataset = dir(dataset_source);

dataset = struct();
dataset_description_filepath = fullfile(dataset_source, 'dataset_description.json');
dataset_description = extract_json_as_struct(dataset_description_filepath);

[participants_data, participants_data_headings] = read_participants_data(dataset_source);


fprintf('Fetching data for %s', sub_dir_name);
sub_key = strrep(sub_dir_name,'-','_');
% disp(sub_key);


sub_data = struct();
sub_data.dataset_description = struct();
sub_data.dataset_description.dataset_name = dataset_description.Name;

subject_id = sub_dir_name(5:end);

sub_path = fullfile(dataset_source, sub_dir_name);
subject_dir = dir(sub_path);

% Get cogent data
sub_data.subject_info = get_subject_data(participants_data, participants_data_headings, subject_id);

% ------------ For each session ------------
for j = 1:length(subject_dir)
    if startsWith(subject_dir(j).name, 'ses-') && subject_dir(j).isdir % For each 'ses-' directory
        ses_dir_name = subject_dir(j).name;
        ses_key = strrep(ses_dir_name,'-','_');
        % disp(ses_key);
        sub_data.(ses_key) = struct();
        
        session_id = subject_dir(j).name(5:end);
        
        ses_path = fullfile(sub_path, subject_dir(j).name, 'beh');
        
        task_name = 'DelayFearConditioning';
        
        
        % ------------ eyetrack ------------
        eyetrack_json_filename = sprintf('sub-%s_ses-%s_task-%s_eyetrack.json', subject_id, session_id, task_name);
        eyetrack_json_filepath = fullfile(ses_path, eyetrack_json_filename);
        
        eyetrack_tsv_filename = sprintf('sub-%s_ses-%s_task-%s_eyetrack.tsv', subject_id, session_id, task_name);
        eyetrack_tsv_filepath = fullfile(ses_path, eyetrack_tsv_filename);
        
        events_json_filename = sprintf('sub-%s_ses-%s_task-%s_events.json', subject_id, session_id, task_name);
        events_json_filepath = fullfile(ses_path, events_json_filename);
        
        events_tsv_filename = sprintf('sub-%s_ses-%s_task-%s_events.tsv', subject_id, session_id, task_name);
        events_tsv_filepath = fullfile(ses_path, events_tsv_filename);
        
        beh_json_filename = sprintf('sub-%s_ses-%s_task-%s_beh.json', subject_id, session_id, task_name);
        beh_json_filepath = fullfile(ses_path, beh_json_filename);
        
        
        sub_data.(ses_key).eyetrack = struct();
        % eyetrack.data
        [eyetrack_data, recoding_duration] = get_eyetrack_data( ...
            eyetrack_json_filepath, eyetrack_tsv_filepath, ...
            events_json_filepath, events_tsv_filepath ...
            );
        sub_data.(ses_key).eyetrack.data = eyetrack_data;
        % eyetrack.info
        sub_data.(ses_key).eyetrack.info = get_eyetrack_info(eyetrack_json_filepath, recoding_duration);
    end
end
end
