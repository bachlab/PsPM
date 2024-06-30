function out = pspm_cfg_run_glm_hp_rew(job)
% Updated on 08-01-2024 by Teddy
global settings
if isempty(settings), pspm_init; end
% set modality
modality = 'hp';
modelspec = 'hp_rew';
f = strcmpi({settings.glm.modelspec}, modelspec);
def_filter = settings.glm(f).filter;
params = pspm_cfg_run_glm(job, def_filter);
% get parameters
model = params.model;
options = params.options;
% basis function
model.bf.fhandle = str2func('pspm_bf_hprf_rew');
model.bf.args = [];
model.modality = modality;
model.modelspec = modelspec;
pspm_glm(model, options);
out = {model.modelfile};
