function [out] = pspm_cfg_run_gaze_pp(job)
% Updated on 08-01-2024 by Teddy
fn = job.datafile{1};
options = struct();
options = pspm_update_struct(options, job, {'channel_action'});
options.channel = pspm_cfg_selector_channel('run', job.chan);
options.channel = options.channel(:);
[sts, out] = pspm_gaze_pp(fn, options);
