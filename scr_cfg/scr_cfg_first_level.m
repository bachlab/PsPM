function cfg = scr_cfg_first_level

% $Id: scr_cfg_first_level.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $


%% First Level
cfg        = cfg_repeat;
cfg.name   = 'First Level';
cfg.tag    = 'first_level';
cfg.values = {scr_cfg_first_level_scr scr_cfg_review1, scr_cfg_contrast1, scr_cfg_export}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {''};