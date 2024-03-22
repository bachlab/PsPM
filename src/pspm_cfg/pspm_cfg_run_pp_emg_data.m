function out = pspm_cfg_run_pp_emg_data(job)
% * Description
%   Executes pspm_emg_pp
% * History
%   Updated with PsPM 6.1.2 in 2024 by Teddy
options = struct();
options.mains_freq = job.options(1).mains_freq;
options.channel_action = job.options(1).chan_action;
options.channel = pspm_cfg_channel_selector('run', job.options(1).chan);
[sts, output] = pspm_emg_pp(job.datafile{1}, options);
if sts == 1
  out = {output.channel};
else
  out = {-1};
end
