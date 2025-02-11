function out = pspm_cfg_run_glm_ra_fc(job)

% initialise
model = struct();
options = struct();

% set modality
model.modality = 'ra';
model.modelspec = 'ra_fc';

% basis function
bf = fieldnames(job.bf);
bf = bf{1};
model.bf.args = subsref(job.bf, struct('type', '.', 'subs', bf));
model.bf.fhandle = str2func('pspm_bf_rarf_fc');

out = pspm_cfg_run_glm(job, model, options);
