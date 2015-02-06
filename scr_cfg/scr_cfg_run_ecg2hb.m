function out = scr_cfg_run_ecg2hb(job)
% Executes scr_ecg2hb

% $Id: scr_cfg_run_ecg2hb.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% channel
if isfield(job.chan,'chan_nr')
    chan = job.chan.chan_nr;
else
    chan = 'ecg';
end

sts = scr_ecg2hb(job.datafile{1}, chan, job.options);

out = job.datafile;

