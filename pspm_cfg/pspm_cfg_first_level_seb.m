function cfg = pspm_cfg_first_level_seb

% $Id$
% $Rev$


%% First Level
cfg        = cfg_repeat;
cfg.name   = 'Startle eyeblink';
cfg.tag    = 'seb';
cfg.values = {pspm_cfg_glm_seb};
cfg.forcestruct = true;
cfg.help   = {''};