function save_pupil_file(pupil_filepath, pupil_data, pupil_info, subject_info)
    % Add subject information to the info struct
    pupil_info.subject = subject_info;  % Add subject struct inside info struct
    
    % Save the pupil data and the modified info struct to the file
    data = pupil_data;
    infos = pupil_info;  % Now contains both pupil info and subject data
    save(pupil_filepath, 'data', 'infos');
end
