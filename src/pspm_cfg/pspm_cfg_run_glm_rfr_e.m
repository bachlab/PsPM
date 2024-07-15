function out = pspm_cfg_run_glm_rfr_e(job)

% initialise
model = struct();
options = struct();

% initialise
model = struct();
options = struct();

% set modality
model.modality = 'rfr';
model.modelspec = 'rfr_e';

% basis function
bf = fieldnames(job.bf);
bf = bf{1};
model.bf.args = subsref(job.bf, struct('type', '.', 'subs', bf));
model.bf.fhandle = str2func('pspm_bf_rfrrf_e');
model.modality = modality;
model.modelspec = modelspec;

out = pspm_cfg_run_glm(job, model, options);
