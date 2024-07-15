function out = pspm_cfg_run_glm_sps(job)

% initialise
model = struct();
options = struct();

% set for only the modality sps
model.modality = 'sps';
model.modelspec = 'sps';

% basis function
rf = fieldnames(job.bf.rf);
rf = rf{1};
soa = job.bf.soa;
if any(strcmpi(rf,{'spsrf_box'}))
  model.bf.fhandle = str2func('pspm_bf_spsrf_box');
  model.bf.args = soa;
elseif any(strcmpi(rf,{'spsrf_gamma'}))
  model.bf.fhandle = str2func('pspm_bf_spsrf_gamma');
  model.bf.args = soa;
end

out = pspm_cfg_run_glm(job, model, options);
