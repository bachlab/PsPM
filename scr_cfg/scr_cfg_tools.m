function cfg = scr_cfg_tools

% $Id$
% $Rev$


%% Preparation
cfg        = cfg_repeat;
cfg.name   = 'Tools';
cfg.tag    = 'tools';
cfg.values = {scr_cfg_display, scr_cfg_rename, scr_cfg_split_sessions, ...
    scr_cfg_artefact_rm, scr_cfg_downsample, scr_cfg_pp_ecg, ... 
    scr_cfg_resp_pp, scr_cfg_interpolate, scr_cfg_find_sounds, ... 
    scr_cfg_process_illuminance, scr_cfg_find_valid_fixations};
cfg.forcestruct = true;
cfg.help   = {'Help: Tools...'};