function pspm_cfg_run_combine_markerchannels(job)
% Updated on 19-12-2023 by Teddy
%% Variables
% fn
fn = job.datafile{1};
% options
options = struct();
if isfield(job, 'channel_action')
  options.channel_action = job.channel_action;
end
if isfield(job, 'marker_chan_num')
  options.channel_action = job.marker_chan_num;
end
%% Run
pspm_combine_markerchannels(fn, options);