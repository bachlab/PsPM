function out = pspm_cfg_run_scr_pp(job)
scr_pp_datafile = job.datafile{1};
scr_pp_options = struct();
scr_pp_options.channel = pspm_cfg_selector_channel('run', job.chan);

scr_pp_options.min = job.options.min;
scr_pp_options.max = job.options.max;
scr_pp_options.slope = job.options.slope;
scr_pp_options.deflection_threshold = job.options.deflection_threshold;
scr_pp_options.data_island_threshold = job.options.data_island_threshold;
scr_pp_options.expand_epochs = job.options.expand_epochs;

scr_pp_options.clipping_step_size = job.options.clipping_detection.clipping_step_size;
scr_pp_options.clipping_window_size = job.options.clipping_detection.clipping_window_size;
scr_pp_options.clipping_threshold = job.options.clipping_detection.clipping_threshold;
scr_pp_options.baseline_jump = job.options.clipping_detection.baseline_jump;
scr_pp_options.include_baseline = job.options.clipping_detection.include_baseline;

if isfield(job.outputtype, 'channel_action')
    scr_pp_options.channel_action = job.outputtype.channel_action;
else
    scr_pp_options.missing_epochs_filename = pspm_cfg_selector_outputfile('run', job.outputtype);
    scr_pp_options.overwrite = job.outputtype.output.overwrite;
end 
[sts, out] = pspm_scr_pp(scr_pp_datafile, scr_pp_options);

