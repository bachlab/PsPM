function out = scr_cfg_run_glm_ps_fc(job)
% Executes scr_glm

% $Id$
% $Rev$

global settings
if isempty(settings), scr_init; end;

def_filter = settings.glm(5).filter;
params = scr_cfg_run_glm(job, def_filter);

% get parameters
model = params.model;
options = params.options;

% basis function
bf = fieldnames(job.bf);
bf = bf{1};
if any(strcmp(bf,{'psrf_fc0', 'psrf_fc1'}))
    model.bf.fhandle = str2func('scr_bf_psrf_fc');
    model.bf.args = job.bf.(bf);
end;

% set modality
model.modality = 'ps';
model.modelspec = 'ps_fc';

out = scr_glm(model, options);
if exist('out', 'var') && isfield(out, 'modelfile')
    if ~iscell(out.modelfile)
        out.modelfile ={out.modelfile};
    end
else
    out(1).modelfile = cell(1);
end;