function glm_scr = scr_cfg_glm_scr
% GLM

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

% load default settings
glm_scr = scr_cfg_glm;

% set callback function
glm_scr.prog = @scr_cfg_run_glm_scr;

% change default filter settings
f = cellfun(@(f) strcmpi('Filter Settings', f.name), glm_scr.val);
filter_settings = glm_scr.val{f};


glm_scr.val{f} = filter_settings;
