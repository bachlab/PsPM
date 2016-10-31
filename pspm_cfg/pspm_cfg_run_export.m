function pspm_cfg_run_export(job)
% Executes pspm_exp

% $Id$
% $Rev$

% datafile
modelfile = job.modelfile;

% target
if isfield(job.target, 'screen')
    target = 'screen';
else
    target = job.target.filename;
end

% datatype
datatype = job.datatype;

% delimiter
delimfield = fieldnames(job.delim);
delim = job.delim.(delimfield{1});


pspm_exp(modelfile, target, datatype, delim);