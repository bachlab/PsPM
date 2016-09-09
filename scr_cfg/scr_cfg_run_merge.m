function [out] = scr_cfg_run_merge(job)

% load input files
infile1 = job.datafiles.first_file;
infile2 = job.datafiles.second_file;

% set reference
ref = job.reference;

% set options
options.overwrite = job.options.overwrite;
options.marker_chan_num = job.options.marker_chan;

% run merge
[out] = scr_merge(infile1, infile2, ref, options);

% ensure output is always a cell
if ~iscell(out)
    out = {out};
end;