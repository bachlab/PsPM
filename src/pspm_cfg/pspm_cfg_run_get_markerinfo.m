function out = pspm_cfg_run_get_markerinfo(job)
% Updated on 19-12-2023 by Teddy
options = struct();
fn = job.datafile{1};
options.filename = pspm_cfg_selector_outputfile('run', job);
options = pspm_update_struct(options, job.output, {'overwrite'});
options.markerchan = pspm_cfg_selector_channel('run', job);
pspm_get_markerinfo(fn, options);
out = {options.filename};
