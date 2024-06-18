function out = pspm_cfg_run_split_sessions(job)
fn = job.datafile{1,1};
options = struct();
options.marker_chan_num = pspm_cfg_selector_channel('run', job.chan);
options.overwrite = job.overwrite;
if isfield(job.missing_epochs_file,'name')
    options.missing = job.missing_epochs_file.name{1,1};
end
% options.missing has a default value in pspm_options if
% unspecified.
if isfield(job.split_behavior, 'auto')
    options.splitpoints = [];
elseif isfield(job.split_behavior, 'marker')
    options.splitpoints = job.split_behavior.marker;
end
[sts, out] = pspm_split_sessions(fn, options);

