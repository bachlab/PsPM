function out = pspm_cfg_run_interpolate(job)
% Updated 18-12-2023 by Teddy
options = struct();
fn = job.datafile{1};
if isfield(job.mode, 'file')
  options = pspm_update_struct(options, job.mode.file, {'overwrite'});
  channel = 'all';
elseif isfield(job.mode, 'channel')
  channel = pspm_cfg_selector_channel('run', job.mode.channel);
  options.newfile = false;
  options = pspm_update_struct(options, job.mode.channel, {'channel_action'});
end
options = pspm_update_struct(options, job, {'extrapolate'});
[~, out] = pspm_interpolate(fn, channel, options);
