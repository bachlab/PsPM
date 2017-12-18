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
    if isfield(job.conversion(i).mode, 'pixel2centimeter')
        width = job.conversion(i).mode.pixel2centimeter.width;
        height = job.conversion(i).mode.pixel2centimeter.height;
        pspm_convert_pixel2cm(fn, chan, width, height, options);
    end
end

out = 1;
