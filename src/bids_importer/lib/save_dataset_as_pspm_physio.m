function save_dataset_as_pspm_physio(dataset, save_path)
disp('Saving physio data as PSPM dataset');
dataset_name = 'PhysioData';  % Adjusted name

if ~isfolder(save_path)
    mkdir(save_path);
end

subjects = fieldnames(dataset.data);

for i = 1:length(subjects)
    mkdir(save_path, subjects{i});
    subject_folder_path = fullfile(save_path, subjects{i});
    sub_id = subjects{i}(5:end);

    % Get the subject info struct
    subject_info = dataset.data.(subjects{i}).subject_info;

    sub_struct_keys = fieldnames(dataset.data.(subjects{i}));
    sessions = sub_struct_keys(startsWith(sub_struct_keys, 'ses_'));

    for j = 1:length(sessions)
        ses_id = sessions{j}(5:end);
        physio_file_name = sprintf('pspm_physio_%s_sn%s.mat', sub_id, ses_id);
        physio_filepath = fullfile(subject_folder_path, physio_file_name);
        save_physio_file(physio_filepath, dataset.data.(subjects{i}).(sessions{j}).physio.data);
        % Info struct will be added later as per your instruction
    end
end
fprintf('Physio dataset saved at %s \n\n', save_path);
end
