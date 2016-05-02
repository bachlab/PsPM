function cfg = scr_cfg

% $Id$
% $Rev$


%% SCR
cfg        = cfg_repeat;
cfg.name   = 'PsPM';
cfg.tag    = 'pspm';
cfg.values = {scr_cfg_preparation, scr_cfg_data_preprocessing, ...
    scr_cfg_first_level, scr_cfg_second_level, scr_cfg_tools};
cfg.forcestruct = true;
cfg.help   = {'Help: PsPM'};