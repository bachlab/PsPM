function out = pspm_cfg_run_glm_hp_rew(job)
% Updated on 08-01-2024 by Teddy

% initialise
model = struct();
options = struct();

% set modality
modality = 'hp';
modelspec = 'hp_rew';

model.modality  = modality;
model.modelspec = modelspec;

% basis function
model.bf.fhandle = str2func('pspm_bf_hprf_rew');
model.bf.args = [];

out = pspm_cfg_run_glm(job, model, options);
