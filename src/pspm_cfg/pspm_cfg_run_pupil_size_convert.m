function [out] = pspm_cfg_run_pupil_size_convert(job)
% Updated on 08-01-2024 by Teddy
fn = job.datafile{1};
options = struct();
options = pspm_update_struct(options, job, {'channel_action'});
options.channel = pspm_cfg_selector_channel('run', job.chan);
if isfield(job.mode, 'area2diameter')
    [sts, out] = pspm_convert_area2diameter(fn, options);
end