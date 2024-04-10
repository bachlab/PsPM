function [out] = pspm_cfg_run_pupil_correct(job)
% Updated on 08-01-2024 by Teddy
fn = job.datafile{1};
options = struct();
options.channel = pspm_cfg_channel_selector('run', job.chan);
options.mode = fieldnames(job.mode);
if strcmp(options.mode, 'auto')
  options = pspm_update_struct(options, job.mode.auto, 'C_z');
else
  options = pspm_update_struct(options, ...
                               job.mode.manual, ...
                               {'C_x', ...
                               'C_y', ...
                               'C_z', ...
                               'S_x', ...
                               'S_y', ...
                               'S_z'});
end
options = pspm_update_struct(options, ...
                             job, ...
                             {'screen_size_px', ...
                             'screen_size_mm', ...
                             'channel_action'});
[~, out{1}] = pspm_pupil_correct_eyelink(fn, options);
end