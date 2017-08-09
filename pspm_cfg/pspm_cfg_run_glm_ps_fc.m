function out = pspm_cfg_run_glm_ps_fc(job)
% Executes pspm_glm

% $Id$
% $Rev$

global settings
if isempty(settings), pspm_init; end

% set modality
modality = 'ps';
modelspec = 'ps_fc';

f = strcmpi({settings.glm.modelspec}, modelspec);
def_filter = settings.glm(f).filter;

params = pspm_cfg_run_glm(job, def_filter);

% get parameters
model = params.model;
options = params.options;

% basis function
bf = fieldnames(job.bf);
bf = bf{1};
if any(strcmp(bf,{'psrf_fc0', 'psrf_fc1', 'psrf_fc2'}))
    model.bf.fhandle = str2func('pspm_bf_psrf_fc');
    switch bf
        case 'psrf_fc0'
            cs = 1;
            cs_d = 0;
            us = 0;
        case 'psrf_fc1'
            cs = 1;
            cs_d = 1;
            us = 0;
        case 'psrf_fc2'
            cs = 1;
            cs_d = 0;
            us = 1;
        case 'psrf_fc3'
            cs = 0;
            cs_d = 0;
            us = 1;
    end
    
    model.bf.args = [cs, cs_d, us];
end

% set default channel (hard coded)
if isfield(job.chan, 'chan_def')
    % get the value of the first field
    fields = fieldnames(job.chan.chan_def);
    s.type = '.';
    s.subs = fields{1};
    model.channel = subsref(job.chan.chan_def, s);
end

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