function [out] = pspm_cfg_run_gaze_convert(job)
% Updated on 26-02-2024 by Teddy
fn = job.datafile{1};
conversion = struct();
conversion = pspm_update_struct(conversion, job, {'from', 'target', 'screen_width', 'screen_height', 'screen_distance'});
options = struct();
options = pspm_update_struct(options, job, {'channel_action'});
options.channel = pspm_cfg_selector_channel('run', job.chan);
[~, out] = pspm_convert_gaze(fn, conversion, options);

