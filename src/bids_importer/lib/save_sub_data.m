function save_sub_data(sub_data, save_path)
    participant_id = sub_data.subject_info.participant_id;
    sub_id = strcat('sub-', participant_id);
    fprintf('Saving data for %s in PSPM format', sub_id);

    dataset_name = sub_data.dataset_description.dataset_name;
    
    sub_struct_keys = fieldnames(sub_data);
    sessions = sub_struct_keys(startsWith(sub_struct_keys, 'ses_'));
    
    for j=1:length(sessions)
        ses_id = sessions{j}(5:end);

        % Save pupil data and include subject_info inside the info struct
        pupil_file_name = sprintf('%s_pupil_%s_sn%s.mat', dataset_name, participant_id, ses_id);
        pupil_filepath = fullfile(save_path, pupil_file_name);
        save_pupil_file(pupil_filepath, ...
            sub_data.(sessions{j}).eyetrack.data, ...
            sub_data.(sessions{j}).eyetrack.info, ...
            sub_data.subject_info ...  % Pass subject info here
        );
    end
end
