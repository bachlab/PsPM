function out = scr_cfg_run_rename(job)
% Executes scr_ren

% $Id: scr_cfg_run_rename.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

n = size(job.file,2);

filename = cell(n,1);
newfilename = cell(1,n);
for i=1:n
    filename{i} = job.file(i).filename{1};
    newfilename{i} = job.file(i).newfilename;
end
out = scr_ren(filename, newfilename);

if ~iscell(out)
    out = {out};
end