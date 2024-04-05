function [out] = pspm_cfg_run_find_valid_fixations(job)
% updated on 19-12-2023 by Teddy
%% Initialise
options = struct();
%% fn
fn = job.datafile{1};
%% bitmap
if isfield(job.val_method,'bitmap_file')
  % bitmap
  try
    indata = load(job.val_method.bitmap_file{1});
  catch
    errmsg = 'Not a matlab data file (i.e no .mat file).';
    warning('ID:invalid_input', errmsg); return;
  end
  if ~isfield(indata,'bitmap')
    warning('ID:invalid_input', ...
      'Indicated file ''%s'' does not contain a matrix called ''bitmap.''',...
      job.val_method.bitmap_file{1});
    return;
  end
  bitmap = indata.bitmap;
else
  % ValidSet
  box_degree = job.val_method.validation_settings.box_degree;
  distance = job.val_method.validation_settings.distance;
  unit = job.val_method.validation_settings.unit;
  options = pspm_update_struct(options, job.val_method.validation_settings, 'resolution');
  if isfield(job.val_method.validation_settings.fixation_point, 'fixpoint')
    options.fixation_point = job.val_method.validation_settings.fixation_point.fixpoint;
  elseif isfield(job.val_method.validation_settings.fixation_point, 'fixpoint_file')
    options.fixation_point = job.val_method.validation_settings.fixation_point.fixpoint_file{1};
  end
end
%% options
options.missing = job.missing;
options.channel = pspm_cfg_channel_selector('run', job.chan); 
options.overwrite = job.output_settings.file_output.overwrite;
options = pspm_update_struct(options, job.output_settings, {'channel_action', ...
                                                            'plot_gaze_coords'});
if isfield(job.output_settings.file_output, 'new_file')
  f_path = job.output_settings.file_output.new_file.file_path{1};
  f_name = job.output_settings.file_output.new_file.file_name;
  options.newfile = [f_path filesep f_name]; % this does not seem to be used at all?
elseif job.output_settings.file_output.overwrite
  options.newfile = '';
end
%% run
if isfield(job.val_method,'bitmap_file')
  [~, out{1}] = pspm_find_valid_fixations(fn, bitmap, options);
else
  [~, out{1}] = pspm_find_valid_fixations(fn, box_degree, ...
    distance, unit, options);
end
