function [out] = pspm_cfg_run_pupil_size_convert(job)
% Updated on 08-01-2024 by Teddy
fn = job.datafile{1};
for i=1:numel(job.conversion)
  options = struct();
  options = pspm_update_struct(options, job, {'channel_action'});
  chan = job.conversion(i).channel;
  if isfield(job.conversion(i).mode, 'area2diameter')
    pspm_convert_area2diameter(fn, chan, options);
  end
end
out = 1;