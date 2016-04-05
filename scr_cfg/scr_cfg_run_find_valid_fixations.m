function [out] = scr_cfg_run_find_valid_fixations(job)

data_file = job.datafile{1};
options = struct();

if isfield(job.validate_fixations, 'enable_fixation_validation')
    options.validate_fixations = 1;
    
    options.box_degree = job.validate_fixations.enable_fixation_validation.box_degree;
    options.distance = job.validate_fixations.enable_fixation_validation.distance;
    
    options.screen_settings = struct();
    options.screen_settings.aspect_actual = ...
        job.validate_fixations.enable_fixation_validation.screen_settings.aspect_actual;
    options.screen_settings.aspect_used = ...
        job.validate_fixations.enable_fixation_validation.screen_settings.aspect_used;
    options.screen_settings.screen_size = ...
        job.validate_fixations.enable_fixation_validation.screen_settings.screen_size;
    
    if isfield(job.validate_fixations.enable_fixation_validation.fixation_point, 'fixpoint')
        options.fixation_point = ...
            job.validate_fixations.enable_fixation_validation.fixation_point.fixpoint;
    elseif isfield(job.validate_fixations.enable_fixation_validation.fixation_point, 'fixpoint_file')
        options.fixation_point = ...
            job.validate_fixations.enable_fixation_validation.fixation_point.fixpoint_file{1};
    end;
else
    options.validate_fixations = 0;
end;

if isfield(job.interpolate, 'enable_interpolation')
    options.interpolate = 1;
end;

if isfield(job.missing, 'enable_missing')
    options.interpolate = 1;
end;

if isfield(job.output_settings.file_output, 'new_file')
    f_path = job.output_settings.file_output.new_file.file_path{1};
    f_name = job.output_settings.file_output.new_file.file_name;
    
    options.newfile = [f_path filesep f_name];
elseif isfield(job.output_settings.file_output, 'overwrite_original')
    options.newfile = '';
    options.overwrite = 1;
end;

if isfield(job.output_settings.channel_output, 'add_channel')
    options.channel_action = 'add';
elseif isfield(job.output_settings.channel_output, 'replace_channel')
    options.channel_action = 'replace';
end;

[~, out{1}] = scr_find_valid_fixations(data_file, options);