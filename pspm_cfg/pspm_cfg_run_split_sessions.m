function out = pspm_cfg_run_split_sessions(job)
% Split sessions

% $Id$
% $Rev$

options = struct;
options.overwrite = job.overwrite;

if isfield(job.mrk_chan,'chan_nr')
    markerchannel = job.mrk_chan.chan_nr;
else
    markerchannel = 0;
end

out = pspm_split_sessions(job.datafile, markerchannel, options);

if ~iscell(out)
    out = {out};
end