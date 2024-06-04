function pspm_cfg_run_data_editor(job)
fn = job.datafile{1};
options = struct();
if isfield(job.outputfile, 'output')
  options.output_file = pspm_cfg_selector_outputfile('run', job.outputfile);
  options.overwrite   = job.outputfile.output.overwrite;
end
if isfield(job.epochs, 'datafile')
    options.epoch_file = job.epochs.datafile{1};
end
pspm_data_editor(fn, options);