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

% exclude conditions with too many NaN 
exclude_missing = job.exclude_missing;

% delimiter
delimfield = fieldnames(job.delim);
delim = job.delim.(delimfield{1});

% place all optional arguments in an option struct 
options = struct();
options.target    = target;
options.statstype = datatype;
options.delim     = delim;
options.exclude_missing = exclude_missing;

pspm_exp(modelfile, options);