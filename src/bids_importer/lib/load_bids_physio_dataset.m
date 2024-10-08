function dataset = load_bids_physio_dataset(dataset_source)
dataset = struct();
[participants_data, participants_data_headings] = read_participants_data(dataset_source);
dataset.participant_information = participants_data_headings;
dataset.data = struct();

% Extract subject key from the dataset source path
sub_key = dataset_source(end-6:end);
sub_key = strrep(sub_key,'-','_');

dataset.data.(sub_key) = struct();

subject_id = sub_key(end-2:end);
sub_path = dataset_source;
subject_dir = dir(sub_path);

% Get participant info
dataset.data.(sub_key).subject_info = get_subject_data(participants_data, participants_data_headings, subject_id);

% Process each session
for j = 1:length(subject_dir)
    if startsWith(subject_dir(j).name, 'ses-') && subject_dir(j).isdir
        ses_dir_name = subject_dir(j).name;
        ses_key = strrep(ses_dir_name,'-','_');
        dataset.data.(sub_key).(ses_key) = struct();
        session_id = subject_dir(j).name(5:end);
        ses_path = fullfile(sub_path, subject_dir(j).name, 'beh');
        task_name = 'DelayFearConditioning';

        % Get physio data
        [physio_data_cell, recording_duration] = get_physio_data(subject_id, session_id, task_name, ses_path);
        dataset.data.(sub_key).(ses_key).physio.data = physio_data_cell;
        % Info struct will be implemented later as per your instruction
    end
end
end
