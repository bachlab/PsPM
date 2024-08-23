function [out] = pspm_cfg_run_merge(job)
% Updated on 08-01-2024 by Teddy
% load input files
infile1 = job.datafiles.first_file{1};
infile2 = job.datafiles.second_file{1};
options = struct();
% set reference
if isfield(job.reference, 'marker')
    options.marker_chan_num = job.reference.marker.chan_nr;
    ref = 'marker';
else
    ref = 'file';
end
% set options
options = pspm_update_struct(options, job, 'overwrite');

% run merge
[sts, out] = pspm_merge(infile1, infile2, ref, options);
