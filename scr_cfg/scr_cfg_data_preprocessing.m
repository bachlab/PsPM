function [cfg] = scr_cfg_data_preprocessing
% function [cfg] = scr_cfg_data_preprocessing
%
% Matlabbatch menu for data preprocessing
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

%% Data preprocessing
cfg        = cfg_repeat;
cfg.name   = 'Data preprocessing';
cfg.tag    = 'data_preprocessing';
cfg.values = {scr_cfg_pp_heart_period, scr_cfg_resp_pp, scr_cfg_pp_pupil, scr_cfg_pp_emg};
cfg.forcestruct = true;
cfg.help   = {'Help: Data preprocessing'};