function out = scr_cfg_run_interpolate(job)

options = struct;
options.overwrite = job.overwrite;
options.limit = struct();

if isfield(job.filter.ulim, 'nolimit')
    options.limit.upper = NaN;
else
    options.limit.upper = job.filter.ulim.ulim;
end


if isfield(job.filter.llim, 'nolimit')
    options.limit.lower = NaN;
else
    options.limit.lower = job.filter.llim.llim;
end


out = {scr_interpolate(job.datafile, options)};