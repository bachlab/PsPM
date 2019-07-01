function [out] = pspm_cfg_run_find_valid_fixations(job)

% $Id$
% $Rev$

data_file = job.datafile{1};
options = struct();

if isfield(job.val_method,'bitmap_file')
    try
        indata = load(job.val_method.bitmap_file{1});
    catch
        errmsg = 'Not a matlab data file (i.e no .mat file).'; 
        warning('ID:invalid_input', errmsg); return;
    end;
    
    if ~isfield(indata,'bitmap')
       warning('ID:invalid_input', 'Indicated file ''%s'' does not contain a matrix called ''bitmap.''',job.val_method.bitmap_file{1}); 
       return;
    end
    bitmap = indata.bitmap;
    
else
    box_degree = job.val_method.validation_settings.box_degree;
    distance = job.val_method.validation_settings.distance;
    unit = job.val_method.validation_settings.unit;
    options.resolution = job.val_method.validation_settings.resolution;
    
    if isfield(job.val_method.validation_settings.fixation_point, 'fixpoint')
        options.fixation_point = ...
            job.val_method.validation_settings.fixation_point.fixpoint;
    elseif isfield(job.val_method.validation_settings.fixation_point, 'fixpoint_file')
        options.fixation_point = ...
            job.val_method.validation_settings.fixation_point.fixpoint_file{1};
    end
end

if isfield(job.missing, 'enable_missing')
    options.missing = 1;
end

if isfield(job, 'eyes')
    options.eyes = job.eyes;
end

options.channels = regexp(job.channels, '\s+', 'split');
% convert numbers
num_vals = str2double(options.channels);
nums = ~isnan(num_vals);

options.channels(nums) = num2cell(num_vals(nums));

if isfield(job.output_settings.file_output, 'new_file')
    f_path = job.output_settings.file_output.new_file.file_path{1};
    f_name = job.output_settings.file_output.new_file.file_name;
    
    options.newfile = [f_path filesep f_name];
elseif isfield(job.output_settings.file_output, 'overwrite_original')
    options.newfile = '';
    options.overwrite = 1;
end

if isfield(job.output_settings.channel_output, 'add_channel')
    options.channel_action = 'add';
elseif isfield(job.output_settings.channel_output, 'replace_channel')
    options.channel_action = 'replace';
end

options.plot_gaze_coords = job.output_settings.plot_gaze_coords;

if isfield(job.val_method,'bitmap_file')
    [~, out{1}] = pspm_find_valid_fixations(data_file,bitmap, options);
else
    [~, out{1}] = pspm_find_valid_fixations(data_file, box_degree, ...
        distance, unit, options);
end
