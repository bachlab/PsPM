function glm_hp_e = scr_cfg_glm_hp_e
% GLM

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

% set variables

vars = struct();
vars.modality = 'HPR';
vars.modspec = 'hp_e';
vars.glmref = { ...
        'Paulus, Castegnetti & Bach (submitted) (Development of the GLM for evoked HPR)' ...
    };
vars.glmhelp = '';

% load default settings
glm_hp_e = scr_cfg_glm(vars);

% set correct name
glm_hp_e.name = 'GLM (evoked)';
glm_hp_e.tag = 'glm_hp_e';

% set callback function
glm_hp_e.prog = @scr_cfg_run_glm_hp_e;

%% Basis function
% change basis function 
% HPRF
n_bf         = cfg_entry;
n_bf.name    = 'Number of basis functions';
n_bf.tag     = 'n_bf';
n_bf.strtype = 'i';
n_bf.num     = [1 Inf];
n_bf.val     = {1:6};
n_bf.help    = {''};

hprf_e        = cfg_branch;
hprf_e.name   = 'HPRF_E';
hprf_e.tag    = 'hprf_e';
hprf_e.val    = {n_bf};
hprf_e.help   = {''};

bf        = cfg_choice;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {hprf_e};
bf.values = {hprf_e};
bf.help   = {['Basis functions. Standard is to use a canonical evoked heart period response function ' ...
    '(HPRF_E) with time derivative for later reconstruction of the response peak.']};

% look for bf and replace
b = cellfun(@(f) strcmpi(f.tag, 'bf'), glm_hp_e.val);
glm_hp_e.val{b} = bf;