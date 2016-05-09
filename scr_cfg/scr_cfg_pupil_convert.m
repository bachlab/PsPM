function cfg = scr_cfg_pupil_convert

% $Id$
% $Rev$


%% Preparation
cfg        = cfg_repeat;
cfg.name   = 'Convert';
cfg.tag    = 'convert';
cfg.values = {};
cfg.forcestruct = true;
cfg.help   = {'Help: Convert...'};