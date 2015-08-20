function out = scr_cfg_run_interpolate(job)

options = struct;
options.overwrite = job.overwrite;

out = {scr_interpolate(job.datafiles, options)};