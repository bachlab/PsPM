function cfg = pspm_cfg_tools



%% Preparation
cfg        = cfg_repeat;
cfg.name   = 'Tools';
cfg.tag    = 'tools';
cfg.values = {pspm_cfg_display, pspm_cfg_rename, pspm_cfg_split_sessions, ...
    pspm_cfg_merge, pspm_cfg_artefact_rm, pspm_cfg_downsample, pspm_cfg_interpolate, ...
    pspm_cfg_extract_segments, pspm_cfg_segment_mean, pspm_cfg_get_markerinfo, ...
    pspm_cfg_data_editor, pspm_cfg_data_convert, pspm_cfg_combine_markerchannels};
cfg.forcestruct = true;
cfg.help   = {'Help: Tools...'};
