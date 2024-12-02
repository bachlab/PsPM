function glm_scr = pspm_cfg_glm_scr
% GLM

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end;

% set variables

vars = struct();
vars.modality = 'SCR';
vars.modspec = 'SCR';

% load default settings
glm_scr = pspm_cfg_glm(vars);

% set callback function
glm_scr.prog = @pspm_cfg_run_glm_scr;

% set correct name
glm_scr.name = 'GLM for SCR';
glm_scr.tag = 'glm_scr';


