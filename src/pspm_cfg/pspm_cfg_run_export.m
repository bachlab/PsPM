function pspm_cfg_run_export(job)
% Updated on 19-12-2023 by Teddy
modelfile = job.modelfile;
if isfield(job.target, 'screen')
  target = 'screen';
else
  target = job.target.filename;
end
delimfield = fieldnames(job.delim);
delim = job.delim.(delimfield{1});
options = struct();
options.delim     = delim;
options.target    = target;
options.statstype = job.datatype;
options = pspm_update_struct(options, job, 'exclude_missing');
% exclude conditions with too many NaN
pspm_exp(modelfile, options);
