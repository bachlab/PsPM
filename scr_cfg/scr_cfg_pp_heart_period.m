function [cfg] = scr_cfg_pp_heart_period
% function [cfg] = scr_cfg_pp_heart_period
%
% Matlabbatch menu for data preprocessing
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

%% Data preprocessing
cfg        = cfg_repeat;
cfg.name   = 'Heart period';
cfg.tag    = 'pp_heart_period';
cfg.values = {scr_cfg_pp_heart_data};
cfg.forcestruct = true;
cfg.help   = {'Help: Heart period preprocessing'};