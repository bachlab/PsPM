function scr_cfg_run_export(job)
% Executes scr_exp

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


scr_exp(modelfile, target, datatype, delim);