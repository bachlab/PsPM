function save_dataset_as_pspm(dataset, save_path)
    disp('Saving as PSPM dataset');
    dataset_name = 'PupilFear';  % Adjusted name

    if ~isfolder(save_path)
        mkdir(save_path);
    end

    subjects = fieldnames(dataset.data);

    for i=1:length(subjects)
        mkdir(save_path, subjects{i});

        subject_folder_path = fullfile(save_path, subjects{i});
        sub_id = subjects{i}(5:end);
        
        % Get the subject info struct
        subject_info = dataset.data.(subjects{i}).subject_info;

        sub_struct_keys = fieldnames(dataset.data.(subjects{i}));
        sessions = sub_struct_keys(startsWith(sub_struct_keys, 'ses_'));
        
        for j=1:length(sessions)
            ses_id = sessions{j}(5:end);

            % Save pupil data and include subject_info inside the info struct
            pupil_file_name = sprintf('%s_pupil_%s_sn%s.mat', dataset_name, sub_id, ses_id);
            pupil_filepath = fullfile(subject_folder_path, pupil_file_name);
            save_pupil_file(pupil_filepath, ...
                dataset.data.(subjects{i}).(sessions{j}).eyetrack.data, ...
                dataset.data.(subjects{i}).(sessions{j}).eyetrack.info, ...
                subject_info ...
            );
        end
    end
    fprintf('Dataset saved at %s \n\n', save_path);
end
