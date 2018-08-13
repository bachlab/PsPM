function out = pspm_cfg_run_glm_sps(job)
% Executes pspm_glm

% $Id: pspm_cfg_run_glm_hp_fc.m 386 2016-11-29 10:30:55Z tmoser $
% $Rev: 386 $

global settings
if isempty(settings), pspm_init; end;

% set modality
modality = 'sps';
modelspec = 'sps';

f = strcmpi({settings.glm.modelspec}, modelspec);
def_filter = settings.glm(f).filter;

params = pspm_cfg_run_glm(job, def_filter);

% get parameters
model = params.model;
options = params.options;

% basis function
rf = fieldnames(job.bf.rf);
rf = rf{1};

soa = job.bf.soa;

if any(strcmpi(rf,{'spsrf_box'}))
    model.bf.fhandle = str2func('pspm_bf_spsrf_box');
    model.bf.args = [soa];
elseif any(strcmpi(rf,{'spsrf_gamma'}))
    model.bf.fhandle = str2func('pspm_bf_spsrf_gamma');
    model.bf.args = [soa];
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

end

