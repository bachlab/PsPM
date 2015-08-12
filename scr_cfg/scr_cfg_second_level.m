function cfg = scr_cfg_second_level

% $Id$
% $Rev$


%% First Level
cfg        = cfg_repeat;
cfg.name   = 'Second Level';
cfg.tag    = 'second_level';
cfg.values = {scr_cfg_contrast2, scr_cfg_review2};
cfg.forcestruct = true;
cfg.help   = {'Help: Second Level...'};