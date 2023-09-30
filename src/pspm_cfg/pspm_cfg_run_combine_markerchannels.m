function pspm_cfg_run_combine_markerchannels(job)
fn = job.datafile{1};
channel_action = job.channel_action;
marker_channel_number = job.marker_chan_num;
options = struct('channel_action', channel_action, ...
                 'marker_chan_num', marker_channel_number);
pspm_combine_markerchannels(fn, options);
