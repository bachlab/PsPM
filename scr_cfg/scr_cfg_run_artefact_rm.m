function out = scr_cfg_run_artefact_rm(job)
% Executes scr_pp

% $Id$
% $Rev$

options = struct;
options.overwrite = job.overwrite;

filtertype = fieldnames(job.filtertype);
filtertype = filtertype{1};
datafile = job.datafile;
datafile = datafile{1};
channelnumber = job.chan_nr;

switch filtertype
    case 'median'
        n = job.filtertype.(filtertype).nr_time_pt;
        out = scr_pp(filtertype, datafile, n, channelnumber, options);
    case 'butter'
        freq = job.filtertype.(filtertype).freq;
        out = scr_pp(filtertype, datafile, freq, channelnumber, options);
end

if ~iscell(out)
    out = {out};
end