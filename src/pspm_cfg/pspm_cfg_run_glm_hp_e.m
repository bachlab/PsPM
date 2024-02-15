function out = pspm_cfg_run_glm_hp_e(job)
% Executes pspm_glm

% $Id$
% $Rev$

global settings
if isempty(settings), pspm_init; end;

% set modality
modality = 'hp';
modelspec = 'hp_e';

f = strcmpi({settings.glm.modelspec}, modelspec);
def_filter = settings.glm(f).filter;

params = pspm_cfg_run_glm(job, def_filter);

% get parameters
model = params.model;
options = params.options;

bf = fieldnames(job.bf);
bf = bf{1};

if strcmpi(bf, 'hprf_e')
    model.bf.fhandle = str2func('pspm_bf_hprf_e');
    model.bf.args = job.bf.hprf_e.n_bf;
elseif isfield(job.bf,'fir')
    model.bf.fhandle = str2func('pspm_bf_FIR');
    model.bf.args = [job.bf.fir.arg.n, job.bf.fir.arg.d];
end;

model.modality = modality;
model.modelspec = modelspec;

out = pspm_glm(model, options);
if exist('out', 'var') && isfield(out, 'modelfile')
    if ~iscell(out.modelfile)
        out.modelfile ={out.modelfile};
    end
else
    out(1).modelfile = cell(1);
end;

