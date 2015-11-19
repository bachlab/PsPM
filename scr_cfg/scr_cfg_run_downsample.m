function out = scr_cfg_run_downsample(job)
% Executes scr_down

% $Id$
% $Rev$

% channels to downsample
if isfield(job.chan,'all_chan')
    chan = 0;
else
    chan = job.chan.chan_vec;
end

% options
options.overwrite = job.overwrite;

[sts, out] = scr_down(job.datafile, job.newfreq, chan, options);

if ~iscell(out)
    out ={out};
end