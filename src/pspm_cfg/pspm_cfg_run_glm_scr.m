function out = pspm_cfg_run_glm_scr(job)

% initialise
model = struct();
options = struct();

% set modality
model.modality = 'scr';
model.modelspec = 'scr';
% basis function
bf = fieldnames(job.bf);
bf = bf{1};
if any(strcmp(bf,{'scrf0', 'scrf1', 'scrf2'}))
  model.bf.fhandle = str2func('pspm_bf_scrf');
  model.bf.args = job.bf.(bf);
elseif isfield(job.bf,'fir')
  model.bf.fhandle = str2func('pspm_bf_FIR');
  model.bf.args = [job.bf.fir.arg.n, job.bf.fir.arg.d];
end

out = pspm_cfg_run_glm(job, model, options);
