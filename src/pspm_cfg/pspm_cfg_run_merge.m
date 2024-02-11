function [out] = pspm_cfg_run_merge(job)
% Updated on 08-01-2024 by Teddy
% load input files
infile1 = job.datafiles.first_file;
infile2 = job.datafiles.second_file;
% set reference
ref = job.reference;
options = struct();
% set options
options = pspm_update_struct(options, job.options, 'overwrite');
if isfield(job.options, 'marker_chan')
  options.marker_chan_num = job.options.marker_chan;
end
% run merge
[out] = pspm_merge(infile1, infile2, ref, options);
% ensure output is always a cell
if ~iscell(out)
  out = {out};
end