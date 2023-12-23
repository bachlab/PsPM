function pspm_cfg_run_combine_markerchannels(job)
% Updated on 19-12-2023 by Teddy
%% Variables
% fn
fn = job.datafile{1};
% options
options = struct();
options = pspm_update_struct(options, job, 'channel_action')
options = pspm_update_struct(options, job, 'marker_chan_num')
%% Run
pspm_combine_markerchannels(fn, options);
