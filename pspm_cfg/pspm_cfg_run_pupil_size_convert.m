function [out] = pspm_cfg_run_pupil_size_convert(job)

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
end

out = 1;
