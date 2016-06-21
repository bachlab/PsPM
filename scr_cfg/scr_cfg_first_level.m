function cfg = scr_cfg_first_level

% $Id$
% $Rev$


%% First Level
cfg        = cfg_repeat;
cfg.name   = 'First Level';
cfg.tag    = 'first_level';
cfg.values = {scr_cfg_first_level_scr, scr_cfg_first_level_hp, ...
    scr_cfg_first_level_resp, ...
    scr_cfg_first_level_ps, scr_cfg_review1, scr_cfg_contrast1, scr_cfg_export}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {''};