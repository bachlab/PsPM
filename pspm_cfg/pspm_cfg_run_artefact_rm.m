function out = pspm_cfg_run_artefact_rm(job)
% Executes pspm_pp

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
        out = pspm_pp(filtertype, datafile, n, channelnumber, options);
    case 'butter'
        freq = job.filtertype.(filtertype).freq;
        out = pspm_pp(filtertype, datafile, freq, channelnumber, options);
    case 'simple_qa'
        qa = job.filtertype.(filtertype);
        out = pspm_pp(filtertype, datafile, qa, channelnumber, options);
end

if ~iscell(out)
    out = {out};
end