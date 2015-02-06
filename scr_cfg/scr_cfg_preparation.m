function cfg = scr_cfg_preparation

% $Id: scr_cfg_preparation.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $


%% Preparation
cfg        = cfg_repeat;
cfg.name   = 'Data Preparation';
cfg.tag    = 'prep';
cfg.values = {scr_cfg_import,scr_cfg_trim}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {'Help: Data Preparation...'};