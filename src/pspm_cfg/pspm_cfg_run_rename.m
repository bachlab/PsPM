function out = pspm_cfg_run_rename(job)
% Updated on 08-01-2024 by Teddy
filename = job.filename{1};
newfilename = job.newfilename;
[sts, out] = pspm_rename(filename, newfilename);
if ~iscell(out)
  out = {out};
end