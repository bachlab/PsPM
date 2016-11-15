function cfg = pspm_cfg_first_level_emg

% $Id$
% $Rev$


%% First Level
cfg        = cfg_repeat;
cfg.name   = 'EMG';
cfg.tag    = 'emg';
cfg.values = {pspm_cfg_dm}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {''};