function out = pspm_cfg_run_glm_hp_e(job)

% initialise
model = struct();
options = struct();

% set modality
model.modality = 'hp';
model.modelspec = 'hp_e';

% get parameters
bf = fieldnames(job.bf);
bf = bf{1};
if strcmpi(bf, 'hprf_e')
  model.bf.fhandle = str2func('pspm_bf_hprf_e');
  model.bf.args = job.bf.hprf_e.n_bf;
elseif isfield(job.bf,'fir')
  model.bf.fhandle = str2func('pspm_bf_FIR');
  model.bf.args = [job.bf.fir.arg.n, job.bf.fir.arg.d];
end

out = pspm_cfg_run_glm(job, model, options);
