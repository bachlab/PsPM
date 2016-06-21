function cfg = scr_cfg_first_level_resp

% $Id$
% $Rev$


%% First Level
cfg        = cfg_repeat;
cfg.name   = 'Respiration';
cfg.tag    = 'resp';
cfg.values = {scr_cfg_glm_ra_e, scr_cfg_glm_ra_fc, scr_cfg_glm_rfr_e, ...
    scr_cfg_glm_rp_e}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {''};