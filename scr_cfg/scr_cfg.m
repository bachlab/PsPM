function cfg = scr_cfg

% $Id: scr_cfg.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $


%% SCR
cfg        = cfg_repeat;
cfg.name   = 'PsPM';
cfg.tag    = 'pspm';
cfg.values = {scr_cfg_preparation, scr_cfg_first_level, scr_cfg_second_level, scr_cfg_tools};
cfg.forcestruct = true;
cfg.help   = {'Help: PsPM'};