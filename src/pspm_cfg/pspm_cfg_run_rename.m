function out = pspm_cfg_run_rename(job)
% Updated on 08-01-2024 by Teddy
n = size(job.file,2);
filename = cell(n,1);
newfilename = cell(1,n);
for i = 1:n
  filename{i} = job.file(i).filename{1};
  newfilename{i} = job.file(i).newfilename;
end
out = pspm_ren(filename, newfilename);
if ~iscell(out)
  out = {out};
end