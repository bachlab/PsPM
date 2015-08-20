function out = scr_cfg_run_glm_hp_fc(job)
% Executes scr_glm

% $Id$
% $Rev$

global settings
if isempty(settings), scr_init; end;

params = scr_cfg_run_glm(job);

% get parameters
model = params.model;
options = params.options;

% set modality
model.modality = 'scr';

out = scr_glm(model, options);
if exist('out', 'var') && isfield(out, 'modelfile')
    if ~iscell(out.modelfile)
        out.modelfile ={out.modelfile};
    end
else
    out(1).modelfile = cell(1);
end;

