function out = pspm_cfg_run_split_sessions(job)
% Split sessions

% $Id$
% $Rev$

options = struct;
options.overwrite = job.overwrite;
if isfield(job.missing_epoch,'path')
    options.missing = job.missing_epoch.path{1,1};
else
    options.missing = 0;
end

if isfield(job.mrk_chan,'chan_nr')
    markerchannel = job.mrk_chan.chan_nr;
else
    markerchannel = 0;
end

if isfield(job.split_behavior, 'auto')
    options.splitpoints = [];
elseif isfield(job.split_behavior, 'marker')
    options.splitpoints = job.split_behavior.marker;
end


out = pspm_split_sessions(job.datafile, markerchannel, options);

if ~iscell(out)
    out = {out};
end