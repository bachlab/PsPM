function pp_scr = pspm_cfg_pp_scr
% function [cfg] = pspm_cfg_pp_scr
%
% Matlabbatch menu for simple skin conductance response (SCR) quality assessment
%__________________________________________________________________________
% PsPM 3.1
% (C) 2021 Dadi Zhao (University College London)

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end;

% Data preprocessing
%cfg        = cfg_repeat;
%cfg.name   = 'SCR quality assessment';
%cfg.tag    = 'pp_scr';
%cfg.values = {pspm_cfg_pp_emg_data}; % To be changed
%cfg.forcestruct = true;
%cfg.help   = {'Help: SCR preprocessing'}; % To be changed