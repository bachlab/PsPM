function [out] = pspm_cfg_run_data_convert(job)

% $Id$
% $Rev$

channel_action = job.channel_action;
fn = job.datafile{1};

for i=1:numel(job.conversion)
    options = struct();
    options.channel_action = channel_action;
    chan = job.conversion(i).channel;
    if isfield(job.conversion(i).mode, 'area2diameter')
        pspm_convert_area2diameter(fn, chan, options);
    end
    if isfield(job.conversion(i).mode, 'pixel2unit')
        width = job.conversion(i).mode.pixel2unit.width;
        height = job.conversion(i).mode.pixel2unit.height;
        unit = job.conversion(i).mode.pixel2unit.unit;
        pspm_convert_pixel2unit(fn, chan, unit, width, height, options);
    end
end

out = 1;
