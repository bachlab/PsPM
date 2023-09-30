function pspm_cfg_run_data_editor(job)
fn = job.datafile{1};
options = struct();
if isfield(job.outputfile, 'enabled')
    options.output_file = [job.outputfile.enabled.file_path{1} filesep ...
        job.outputfile.enabled.file_name];
end
pspm_data_editor(fn, options);
