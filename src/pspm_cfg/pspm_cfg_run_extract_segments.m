function [out] = pspm_cfg_run_extract_segments(job)
% Updated on 25-12-2023 by Teddy
out = {};

if isfield(job, 'mode')
  if isfield(job.mode, 'mode_automatic')
    mode = 'model';
    glm_file = job.mode.mode_automatic.datafile{1};
  elseif isfield(job.mode, 'mode_manual')
    mode = 'file';
    chan = pspm_cfg_channel_selector('run', job.mode.mode_manual);
    % call common data & design selector
    [model, options] = pspm_cfg_data_design_selector('run', job.mode.mode_manual);
    data_fn = model.datafile;
    timing = model.timing;
    if isfield(model, 'missing')
        options.missing = model.missing;
    end
    options.timeunits = model.timeunits;
  end

  options.length = job.options.segment_length;
  field_name_nan_output = fieldnames(job.options.nan_output);
  switch field_name_nan_output{1}
    case 'nan_none'
      options.nan_output = 'none';
    case 'nan_screen'
      options.nan_output = 'screen';
    case 'nan_output_file'
      options.nan_output = pspm_cfg_selector_outputfile('run', job.options.nan_output);
  end
  % extract output
  options.outputfile = pspm_cfg_selector_outputfile('run', job.output);
  options.overwrite  = job.output.output.overwrite;
  options.plot       = job.output.plot;
  switch mode
      case 'model'
      [~, out] = pspm_extract_segments(mode, glm_file, options);
      case 'file'
      [~, out] = pspm_extract_segments(mode, data_fn, chan, timing, options);
  end
else
  warning('ID:invalid_input', 'No mode specified');
end
