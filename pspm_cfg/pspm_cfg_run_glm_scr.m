function out = pspm_cfg_run_glm_scr(job)
% Executes pspm_glm

% $Id$
% $Rev$

global settings
if isempty(settings), pspm_init; end;

def_filter = settings.glm(1).filter;
params = pspm_cfg_run_glm(job, def_filter);

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

% get parameters
model = params.model;
options = params.options;

% set modality
model.modality = 'scr';
model.modelspec = 'scr';

out = pspm_glm(model, options);
if exist('out', 'var') && isfield(out, 'modelfile')
    if ~iscell(out.modelfile)
        out.modelfile ={out.modelfile};
    end
else
    out(1).modelfile = cell(1);
end;

