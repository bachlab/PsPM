function out = pspm_cfg_run_glm_hp_fc(job)

% initialise
model = struct();
options = struct();

% set modality
model.modality = 'hp';
model.modelspec = 'hp_fc';

% basis function
rf = fieldnames(job.bf.rf);
rf = rf{1};
soa = job.bf.soa;
if any(strcmp(rf,{'hprf_fc0', 'hprf_fc1'}))
  model.bf.fhandle = str2func('pspm_bf_hprf_fc');
  model.bf.args = [job.bf.rf.(rf) soa];
end

out = pspm_cfg_run_glm(job, model, options);
