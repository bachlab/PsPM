function out = pspm_cfg_run_glm_seb(job)
% Executes pspm_glm

% $Id$
% $Rev$

global settings
if isempty(settings), pspm_init; end

% set modality
modality = 'sebr';
modelspec = 'sebr';

f = strcmpi({settings.glm.modelspec}, modelspec);
def_filter = settings.glm(f).filter;

params = pspm_cfg_run_glm(job, def_filter);

% get parameters
model = params.model;
options = params.options;

% basis function
rf = fieldnames(job.bf.rf);
rf = rf{1};

if any(strcmp(rf,{'sebrf0', 'sebrf1'}))
    model.bf.fhandle = str2func('pspm_bf_sebrf');
    
    if strcmp(rf, 'sebrf0')
        model.bf.args = [];
    elseif strcmp(rf, 'sebrf1')
        model.bf.args = 1;
    end
end

% set modality
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
