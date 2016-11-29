function out = pspm_cfg_run_glm_ra_e(job)
% Executes pspm_glm

% $Id$
% $Rev$

global settings
if isempty(settings), pspm_init; end;

% set modality
modality = 'ra';
modelspec = 'ra_e';

f = strcmpi({settings.glm.modelspec}, modelspec);
def_filter = settings.glm(f).filter;

params = pspm_cfg_run_glm(job, def_filter);

% get parameters
model = params.model;
options = params.options;

% basis function
bf = fieldnames(job.bf);
bf = bf{1};
model.bf.args = subsref(job.bf, struct('type', '.', 'subs', bf));
model.bf.fhandle = str2func('pspm_bf_rarf_e');

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