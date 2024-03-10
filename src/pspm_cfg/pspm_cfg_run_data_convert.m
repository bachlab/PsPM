function [out] = pspm_cfg_run_data_convert(job)
% Updated on 19-12-2023 by Teddy
fn = job.datafile{1};
for i = 1:numel(job.conversion)
  options = struct();
  options = pspm_update_struct(options, job, 'channel_action');
  if isfield(job.conversion(i).mode, 'area2diameter')
    fn = job.datafile;
    chan = job.conversion(i).channel;
    pspm_convert_area2diameter(fn, chan, options);
  end
  if isfield(job.conversion(i).mode, 'pixel2unit')
    width = job.conversion(i).mode.pixel2unit.width;
    height = job.conversion(i).mode.pixel2unit.height;
    distance = job.conversion(i).mode.pixel2unit.distance;
    unit = job.conversion(i).mode.pixel2unit.unit;
    chan = job.conversion(i).channel;
    pspm_convert_pixel2unit(fn, chan, unit, width, height,distance, options);
  end
  if isfield(job.conversion(i).mode, 'visangle2sps')
    options = pspm_update_struct(options, job.conversion(i), 'channel');
    options = pspm_update_struct(options, job.conversion(i).mode.visangle2sps, 'eyes');
    pspm_convert_visangle2sps(fn, options);
  end
end
out = 1;
