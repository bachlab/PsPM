function pspm_cfg_run_export(job)
% Updated on 19-12-2023 by Teddy
modelfile = job.modelfile;
if isfield(job.target, 'screen')
  target = 'screen';
else
  target = job.target.filename;
end
datatype = job.datatype;
exclude_missing = job.exclude_missing; % exclude conditions with too many NaN
delimfield = fieldnames(job.delim);
delim = job.delim.(delimfield{1});
options = struct();
options.target          = target;
options.statstype       = datatype;
options.delim           = delim;
options.exclude_missing = exclude_missing;
pspm_exp(modelfile, options);
