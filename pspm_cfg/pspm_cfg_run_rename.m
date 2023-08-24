function out = pspm_cfg_run_rename(job)
% Executes pspm_ren

% $Id$
% $Rev$

n = size(job.file,2);

filename = cell(n,1);
newfilename = cell(1,n);
for i=1:n
    filename{i} = job.file(i).filename{1};
    newfilename{i} = job.file(i).newfilename;
end
out = pspm_ren(filename, newfilename);

if ~iscell(out)
    out = {out};
end
