function out = pspm_cfg_run_resp_pp(job)
sr = job.sr;% sample rate
resp_pp_options = struct();
resp_pp_options.channel = pspm_cfg_selector_channel('run', job.chan);
resp_pp_options.plot = job.options.plot;
if isfield(job.options.systemtype, 'bellows')
    resp_pp_options.systemtype = 'bellows';
else
    resp_pp_options.systemtype = 'cushion';
end
f = fields(job.options.datatype);
resp_pp_options.datatype = {};
for i = 1:numel(f)
    if job.options.datatype.(f{i}) == 1
        resp_pp_options.datatype = [resp_pp_options.datatype, f{i}];
    end
end
resp_pp_options.channel_action = job.channel_action;
[sts, out] = pspm_resp_pp(job.datafile{1}, sr, resp_pp_options);


