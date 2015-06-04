function out = scr_cfg_run_resp2rp(job)
% Executes scr_resp2rp

% $Id: scr_cfg_run_resp2rp.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% sample rate
sr = job.sr;

% channel
if isfield(job.chan,'chan_nr')
    chan = job.chan.chan_nr;
else
    chan = 'resp';
end

options.plot = job.plot;



sts = scr_hb2hr(job.datafile{1}, sr, chan, options.plot);

out = job.datafile;