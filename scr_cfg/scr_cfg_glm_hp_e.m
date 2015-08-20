function glm_hp_e = scr_cfg_glm_hp_e
% GLM

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

% load default settings
glm_hp_e = scr_cfg_glm;

change = { ...
    struct('path', {{'filter','edit','direction'}}, ...
            'field', 'val', 'value', {{'bi'}} ...
        ) ...
    };



[sts, glm_hp_e] = scr_cfg_change_field(glm_hp_e, change);

% set correct name
glm_hp_e.name = 'GLM (evoked)';

% set callback function
glm_hp_e.prog = @scr_cfg_run_glm_hp_e;