function [out] = pspm_cfg_run_pupil_preprocess(job)
% Updated on 08-01-2024 by Teddy
fn = job.datafile{1};
options = struct();
chankey = fieldnames(job.channel);
chankey = chankey{1};
options.channel = job.channel.(chankey);
chankey = fieldnames(job.channel_combine);
chankey = chankey{1};
options.channel_combine = job.channel_combine.(chankey);
settkey = fieldnames(job.settings);
settkey = settkey{1};
if strcmp(settkey, 'custom_settings')
  options = pspm_update_struct(options, job.settings, 'custom_settings');
end
options.segments = {};
for i = 1:numel(job.segments)
  options.segments{end + 1} = job.segments(i);
end
options = pspm_update_struct(options, job, {'channel_action','plot_data'});
[~, out{1}] = pspm_pupil_pp(fn, options);
end