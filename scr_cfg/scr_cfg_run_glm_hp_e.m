function out = scr_cfg_run_glm_hp_e(job)
% Executes scr_glm

% $Id$
% $Rev$

global settings
if isempty(settings), scr_init; end;

params = scr_cfg_run_glm(job);

% get parameters
model = params.model;
options = params.options;

bf = fieldnames(job.bf);
bf = bf{1};

if strcmpi(bf, 'hprf_e')
    model.bf.fhandle = str2func('scr_bf_hprf_e');
    model.bf.args = job.bf.hprf_e.n_bf;
elseif isfield(job.bf,'fir')
    model.bf.fhandle = str2func('scr_bf_FIR');
    model.bf.args = [job.bf.fir.arg.n, job.bf.fir.arg.d];
end;

% set modality
model.modality = 'hp';
model.modelspec = 'hp_e';

out = scr_glm(model, options);
if exist('out', 'var') && isfield(out, 'modelfile')
    if ~iscell(out.modelfile)
        out.modelfile ={out.modelfile};
    end
else
    out(1).modelfile = cell(1);
end;

