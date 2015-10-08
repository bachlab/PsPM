function out = scr_cfg_run_glm_scr(job)
% Executes scr_glm

% $Id$
% $Rev$

global settings
if isempty(settings), scr_init; end;

def_filter = settings.glm(1).filter;
params = scr_cfg_run_glm(job, def_filter);

% basis function
bf = fieldnames(job.bf);
bf = bf{1};
if any(strcmp(bf,{'scrf0', 'scrf1', 'scrf2'}))
    model.bf.fhandle = str2func('scr_bf_scrf');
    model.bf.args = job.bf.(bf);
elseif isfield(job.bf,'fir')
    model.bf.fhandle = str2func('scr_bf_FIR');
    model.bf.args = [job.bf.fir.arg.n, job.bf.fir.arg.d];
end

% get parameters
model = params.model;
options = params.options;

% set modality
model.modality = 'scr';
model.modelspec = 'scr';

out = scr_glm(model, options);
if exist('out', 'var') && isfield(out, 'modelfile')
    if ~iscell(out.modelfile)
        out.modelfile ={out.modelfile};
    end
else
    out(1).modelfile = cell(1);
end;

