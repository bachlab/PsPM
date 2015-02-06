function out = scr_cfg_run_downsample(job)
% Executes scr_down

% $Id: scr_cfg_run_downsample.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% channels to downsample
if isfield(job.chan,'all_chan')
    chan = 0;
else
    chan = job.chan.chan_vec;
end

% options
options.overwrite = job.overwrite;

out = scr_down(job.datafile, job.newfreq, chan, options);

if ~iscell(out)
    out ={out};
end