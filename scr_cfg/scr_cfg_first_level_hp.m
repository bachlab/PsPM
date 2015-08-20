function cfg = scr_cfg_first_level_hp

% $Id$
% $Rev$


%% First Level
cfg        = cfg_repeat;
cfg.name   = 'Heart period';
cfg.tag    = 'hp';
cfg.values = {scr_cfg_glm_hp_e, scr_cfg_glm_hp_fc}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {''};