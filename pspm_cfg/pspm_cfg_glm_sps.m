function [glm_sps] = pspm_cfg_glm_sps
% GLM SPS

% $Id: pspm_cfg_glm_hp_fc.m 404 2017-01-06 14:02:02Z tmoser $
% $Rev: 404 $

% Initialise
global settings
if isempty(settings), pspm_init; end;

% set variables

vars = struct();
vars.modality = 'sps';
vars.modspec = 'sps';
vars.glmref = {['unknown'] };
vars.glmhelp = '';

% load default settings
glm_sps = pspm_cfg_glm(vars);

% set correct name
glm_sps.name = 'GLM for SPS';
glm_sps.tag = 'glm_sps';

% set callback function
glm_sps.prog = @pspm_cfg_run_glm_sps;

%% SOA
soa         = cfg_entry;
soa.name    = 'SOA';
soa.tag     = 'soa';
soa.help    = {['Specify custom SOA for response function. Tested values are 3.5s, 4s and 6s. Default: 3.5s']};
soa.strtype = 'r';
soa.num     = [1 1];
soa.val     = {3.5};

%% Basis function
% SPS
% bf = boxfunction
spsrf_box = cfg_const;
spsrf_box.name = 'Boxfunction';
spsrf_box.tag = 'spsrf_box';
spsrf_box.val = {'spsrf_box'};
spsrf_box.help = {['SPSRF with boxfunction. (default)']};

% bf = gammafunction
spsrf_gamma = cfg_const;
spsrf_gamma.name = 'Gammafunction';
spsrf_gamma.tag = 'spsrf_gamma';
spsrf_gamma.val = {'spsrf_gamma'};
spsrf_gamma.help = {['SPSRF with gammafunction.']};

rf        = cfg_choice;
rf.name   = 'Function';
rf.tag    = 'rf';
rf.val    = {spsrf_box};
rf.values = {spsrf_box,spsrf_gamma};

bf        = cfg_branch;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {rf,soa};
bf.help   = {['Basis functions.']};

% look for bf and replace
b = cellfun(@(f) strcmpi(f.tag, 'bf'), glm_sps.val);
glm_sps.val{b} = bf;
