function out = pspm_cfg_run_combine_markerchannels(job)
% Updated on 19-12-2023 by Teddy
%% Variables
% fn
fn = job.datafile{1};
% options
options = struct();
options = pspm_update_struct(options, job, {'channel_action'});
options.marker_chan_num = pspm_cfg_selector_channel('run', job);
%% Run
[~, out] = pspm_combine_markerchannels(fn, options);
