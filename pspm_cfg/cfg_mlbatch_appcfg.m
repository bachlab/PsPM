function [cfg, def] = cfg_mlbatch_appcfg(varargin)
% 'SCR' - MATLABBATCH cfg_util initialisation
% This MATLABBATCH initialisation file can be used to load application
%              'SCR'
% into cfg_util. This can be done manually by running this file from
% MATLAB command line or automatically when cfg_util is initialised.
% The directory containing this file and the configuration file
%              'pspm_cfg_appcfg'
% must be in MATLAB's path variable.
% Created at 2013-11-07 11:21:54.

% Get path to this file and add it to MATLAB path.
% If the configuration file is stored in another place, the path must be adjusted here.
p = fileparts(mfilename('fullpath'));
addpath(p);
% run configuration main & def function, return output
cfg = pspm_cfg;
def = [];
