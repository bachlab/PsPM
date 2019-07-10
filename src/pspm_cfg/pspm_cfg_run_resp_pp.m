function out = pspm_cfg_run_resp_pp(job)
% Executes pspm_resp_pp

% $Id: pspm_cfg_run_resp_pp.m 450 2017-07-03 15:17:02Z tmoser $
% $Rev: 450 $

% sample rate
sr = job.sr;

% channel
if isfield(job.chan,'chan_nr')
    chan = job.chan.chan_nr;
else
    chan = '';
end

options.plot = job.options.plot;

if isfield(job.options.systemtype, 'bellows')
    options.systemtype = 'bellows';
else
    options.systemtype = 'cushion';
end

f = fields(job.options.datatype);

options.datatype = {};
for i = 1:numel(f)
    if job.options.datatype.(f{i}) == 1
        options.datatype = [options.datatype, f{i}];
    end;
end;

options.channel_action = job.channel_action;

sts = pspm_resp_pp(job.datafile{1}, sr, chan, options);

out = job.datafile;
