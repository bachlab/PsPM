function out = pspm_cfg_run_emg_pp(job)
% ● Description
%   Executes pspm_emg_pp
% ● History
%   Updated with PsPM 6.1.2 in 2024 by Teddy
options = struct();
options.mains_freq = job.options(1).mains_freq;
options.channel_action = job.options(1).channel_action;
options.channel = pspm_cfg_selector_channel('run', job.options(1).chan);
[sts, out] = pspm_emg_pp(job.datafile{1}, options);
