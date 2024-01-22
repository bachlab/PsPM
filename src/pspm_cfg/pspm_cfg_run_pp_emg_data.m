function out = pspm_cfg_run_pp_emg_data(job)
% Executes pspm_emg_pp

options = struct();
options.mains_freq = job.options(1).mains_freq;
options.channel_action = job.options(1).chan_action;
if isfield(job.options(1).channel, 'cust_channel')
    options.channel = job.options(1).channel(1).cust_channel;
elseif isfield(job.options(1).channel, 'first_channel')
    options.channel = job.options(1).channel(1).first_channel;
end;

[sts, output] = pspm_emg_pp(job.datafile{1}, options);

if sts == 1
    out = {output.channel};
else
    out = {-1};
end;
