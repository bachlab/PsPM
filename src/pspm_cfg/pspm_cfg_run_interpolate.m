function out = pspm_cfg_run_interpolate(job)
% Updated 18-12-2023 by Teddy
options = struct();
fn = job.datafiles;
if isfield(job.mode, 'file')
  options = pspm_update_struct(options, job.mode.file, {'overwrite'});
  options.newfile = true;
elseif isfield(job.mode, 'channel')
  options.channels = cell(size(job.datafiles));
  options.channels{:} = job.mode.channel.source_chan;
  options.newfile = false;
  if isfield(job.mode.channel.mode, 'new_chan')
    options.channel_action = 'add';
  elseif isfield(job.mode.channel.mode, 'replace_chan')
    options.channel_action = 'replace';
  end
end
options = pspm_update_struct(options, job, {'extrapolate'});
[~, out] = pspm_interpolate(fn, options);
