function cfg = scr_cfg_second_level

% $Id: scr_cfg_second_level.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $


%% First Level
cfg        = cfg_repeat;
cfg.name   = 'Second Level';
cfg.tag    = 'second_level';
cfg.values = {scr_cfg_contrast2, scr_cfg_review2};
cfg.forcestruct = true;
cfg.help   = {'Help: Second Level...'};