function cfg = scr_cfg_preparation

% $Id$
% $Rev$


%% Preparation
cfg        = cfg_repeat;
cfg.name   = 'Data Preparation';
cfg.tag    = 'prep';
% interpolation function TODO: move to tools
%cfg.values = {scr_cfg_import,scr_cfg_trim, scr_cfg_interpolate}; % Values in a cfg_repeat can be any cfg_item objects
cfg.values = {scr_cfg_import,scr_cfg_trim}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {'Help: Data Preparation...'};