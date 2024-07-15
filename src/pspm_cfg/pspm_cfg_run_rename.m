function out = pspm_cfg_run_rename(job)
% Updated on 08-01-2024 by Teddy
filename = job.datafile{1};
newfilename = pspm_cfg_selector_outputfile('run', job);
options = struct();
options.overwrite = job.output.overwrite;
[sts, out] = pspm_rename(filename, newfilename, options);
if ~iscell(out)
  out = {out};
end