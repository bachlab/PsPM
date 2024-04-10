function out = pspm_cfg_run_glm_hp_fc(job)
% Updated on 08-01-2024 by Teddy
global settings
if isempty(settings), pspm_init; end
% set modality
modality = 'hp';
modelspec = 'hp_fc';
f = strcmpi({settings.glm.modelspec}, modelspec);
def_filter = settings.glm(f).filter;
params = pspm_cfg_run_glm(job, def_filter);
% get parameters
model = params.model;
options = params.options;
% basis function
rf = fieldnames(job.bf.rf);
rf = rf{1};
soa = job.bf.soa;
if any(strcmp(rf,{'hprf_fc0', 'hprf_fc1'}))
  model.bf.fhandle = str2func('pspm_bf_hprf_fc');
  model.bf.args = [job.bf.rf.(rf) soa];
end
model.modality = modality;
model.modelspec = modelspec;
out = pspm_glm(model, options);
if exist('out', 'var') && isfield(out, 'modelfile')
  if ~iscell(out.modelfile)
    out.modelfile ={out.modelfile};
  end
else
  out(1).modelfile = cell(1);
end