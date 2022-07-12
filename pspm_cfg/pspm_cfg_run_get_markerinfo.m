function out = pspm_cfg_run_get_markerinfo(job)
% Get Markerinfo

% $Id$
% $Rev$

options = struct();
fn = job.datafile{1};

out_fn = job.output.file.file_name;
out_path = job.output.file.file_path{1};

[pathstr, name, ~] = fileparts([out_path filesep out_fn]);
options.filename = [pathstr filesep name '.mat'];
options.overwrite = job.output.overwrite;

if isfield(job.mrk_chan, 'chan_nr')
    options.markerchan = job.mrk_chan.chan_nr;
else
    options.markerchan = -1;
end;


pspm_get_markerinfo(fn, options);
out = {options.filename};