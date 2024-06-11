function out = pspm_cfg_run_glm_rp_e(job)

% initialise
model = struct();
options = struct();

% set modality
model.modality = 'rp';
model.modelspec = 'rp_e';

% basis function
bf = fieldnames(job.bf);
bf = bf{1};
model.bf.args = subsref(job.bf, struct('type', '.', 'subs', bf));
model.bf.fhandle = str2func('pspm_bf_rprf_e');

out = pspm_cfg_run_glm(job, model, options);

