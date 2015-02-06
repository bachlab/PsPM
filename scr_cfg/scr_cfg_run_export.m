function scr_cfg_run_export(job)
% Executes scr_exp

% $Id: scr_cfg_run_export.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

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