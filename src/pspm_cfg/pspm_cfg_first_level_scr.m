function cfg = pspm_cfg_first_level_scr

% $Id$
% $Rev$


%% First Level
cfg        = cfg_repeat;
cfg.name   = 'SCR';
cfg.tag    = 'scr';
cfg.values = {pspm_cfg_glm_scr, pspm_cfg_dcm, pspm_cfg_sf}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {''};
