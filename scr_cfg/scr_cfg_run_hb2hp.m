function out = scr_cfg_run_hb2hp(job)
% Executes scr_hb2hp

% $Id: scr_cfg_run_hb2hp.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% sample rate
sr = job.sr;

% channel
if isfield(job.chan,'chan_nr')
    chan = job.chan.chan_nr;
    sts = scr_hb2hr(job.datafile{1}, sr, chan);
else
    sts = scr_hb2hr(job.datafile{1}, sr);
end

out = job.datafile;