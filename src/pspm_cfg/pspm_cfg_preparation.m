function cfg = pspm_cfg_preparation

% $Id$
% $Rev$


%% Preparation
cfg        = cfg_repeat;
cfg.name   = 'Data Preparation';
cfg.tag    = 'prep';
cfg.values = {pspm_cfg_import,pspm_cfg_trim,pspm_cfg_combine_markerchannels}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {'Help: Data Preparation...'};
