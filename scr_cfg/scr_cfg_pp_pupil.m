function [cfg] = scr_cfg_pp_pupil
% function [cfg] = scr_cfg_pp_pupil
%
% Matlabbatch menu for data preprocessing
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

%% Data preprocessing
cfg        = cfg_repeat;
cfg.name   = 'Pupil & Eye tracking';
cfg.tag    = 'pp_pupil';
cfg.values = {scr_cfg_process_illuminance, scr_cfg_find_valid_fixations, ...
    scr_cfg_pupil_data_convert};
cfg.forcestruct = true;
cfg.help   = {'Help: Pupil & Eye tracking preprocessing'};