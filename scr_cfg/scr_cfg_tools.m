function cfg = scr_cfg_tools

% $Id: scr_cfg_tools.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $


%% Preparation
cfg        = cfg_repeat;
cfg.name   = 'Tools';
cfg.tag    = 'tools';
cfg.values = {scr_cfg_display, scr_cfg_rename, scr_cfg_split_sessions, scr_cfg_artefact_rm, scr_cfg_downsample, scr_cfg_ecg2hb, scr_cfg_hb2hp, scr_cfg_resp2rp}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {'Help: Tools...'};