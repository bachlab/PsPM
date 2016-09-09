function cfg = scr_cfg_tools

% $Id$
% $Rev$


%% Preparation
cfg        = cfg_repeat;
cfg.name   = 'Tools';
cfg.tag    = 'tools';
cfg.values = {scr_cfg_display, scr_cfg_rename, scr_cfg_split_sessions, ...
    scr_cfg_merge, scr_cfg_artefact_rm, scr_cfg_downsample, scr_cfg_interpolate, ... 
    scr_cfg_extract_segments, scr_cfg_segment_mean, scr_cfg_get_markerinfo, ...
    scr_cfg_data_editor};
cfg.forcestruct = true;
cfg.help   = {'Help: Tools...'};