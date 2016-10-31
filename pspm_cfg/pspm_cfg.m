function cfg = pspm_cfg

% $Id$
% $Rev$


%% SCR
cfg        = cfg_repeat;
cfg.name   = 'PsPM';
cfg.tag    = 'pspm';
cfg.values = {pspm_cfg_preparation, pspm_cfg_data_preprocessing, ...
    pspm_cfg_first_level, pspm_cfg_second_level, pspm_cfg_tools};
cfg.forcestruct = true;
cfg.help   = {'Help: PsPM'};