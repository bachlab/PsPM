function cfg = pspm_cfg_first_level

% $Id$
% $Rev$


%% First Level
cfg        = cfg_repeat;
cfg.name   = 'First Level';
cfg.tag    = 'first_level';
cfg.values = {pspm_cfg_first_level_scr, pspm_cfg_first_level_hp, ...
    pspm_cfg_first_level_resp, ...
    pspm_cfg_first_level_ps, ...
    pspm_cfg_first_level_sebr, ...
    pspm_cfg_first_level_sps, ...
    pspm_cfg_review1, pspm_cfg_contrast1, pspm_cfg_export}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {''};
