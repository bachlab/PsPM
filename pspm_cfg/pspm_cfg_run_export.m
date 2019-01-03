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
% datatype = job.datatype;
if isfield(job.datatype,'param')
   datatype = job.datatype.param;
   excl_cond = false;
elseif isfield(job.datatype,'cond')
    datatype = 'cond';
    excl_cond = job.datatype.cond.excl_op;
else
   datatype = job.datatype.recon;
   excl_cond = false;
end

% delimiter
delimfield = fieldnames(job.delim);
delim = job.delim.(delimfield{1});

% place all optional arguments in an option struct 
options = struct();
options.target    = target;
options.statstype = datatype;
options.delim     = delim;
options.excl_cond = excl_cond;

pspm_exp(modelfile, options);