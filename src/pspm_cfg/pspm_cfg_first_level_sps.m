function cfg = pspm_cfg_first_level_sps

% $Id: pspm_cfg_first_level_sebr.m 432 2017-04-03 13:17:00Z tmoser $
% $Rev: 432 $


%% First Level
cfg        = cfg_repeat;
cfg.name   = 'Scanpath speed';
cfg.tag    = 'sps';
cfg.values = {pspm_cfg_glm_sps};
cfg.forcestruct = true;
cfg.help   = {''};

