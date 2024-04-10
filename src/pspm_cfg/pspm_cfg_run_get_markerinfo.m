function out = pspm_cfg_run_get_markerinfo(job)
% Updated on 19-12-2023 by Teddy
options = struct();
fn = job.datafile{1};
out_fn = job.output.file.file_name;
out_path = job.output.file.file_path{1};
[pathstr, name, ~] = fileparts([out_path filesep out_fn]);
options.filename = [pathstr filesep name '.mat'];
options = pspm_update_struct(options, job.output, {'overwrite'});
options.markerchan = pspm_cfg_channel_selector('run', job.chan);
pspm_get_markerinfo(fn, options);
out = {options.filename};
