function out = scr_cfg_run_split_sessions(job)
% Split sessions

% $Id: scr_cfg_run_split_sessions.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

options = struct;
options.overwrite = job.overwrite;

if isfield(job.mrk_chan,'chan_nr')
    markerchannel = job.mrk_chan.chan_nr;
else
    markerchannel = 0;
end

out = scr_split_sessions(job.datafile, markerchannel, options);

if ~iscell(out)
    out = {out};
end