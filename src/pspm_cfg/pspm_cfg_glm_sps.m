function [glm_sps] = pspm_cfg_glm_sps
% GLM SPS
% This function applies to the glm model for the modality ScanPath Speed (sps) only

% $Id: pspm_cfg_glm_sps.m 404 2017-01-06 14:02:02Z tmoser $
% $Rev: 404 $

% Updated by Teddy (WCHN)

% Initialise
global settings
if isempty(settings)
    pspm_init;
end

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
soa.help    = {['Specify custom SOA for response function.', ...
 'Tested values are 3.5 s and 4 s.', ...
 'Default: 3.5 s']};
soa.strtype = 'r';
soa.num     = [1 1];
soa.val     = {3.5};

%% Basis function
% SPS
% bf = boxfunction
spsrf_box = cfg_const;
spsrf_box.name = 'Average scanpath speed';
spsrf_box.tag = 'spsrf_box';
spsrf_box.val = {'spsrf_box'};
spsrf_box.help = {['This option implements a boxcar function over the SOA, and yields the average ',...
 'scan path speed over that interval (i.e.', ...
 'the scan path length over that interval, divided by the SOA).', ...
 '(default).']};

% bf = gammafunction
spsrf_gamma = cfg_const;
spsrf_gamma.name = 'SPSRF_FC';
spsrf_gamma.tag = 'spsrf_gamma';
spsrf_gamma.val = {'spsrf_gamma'};
spsrf_gamma.help = {['This option implements a gamma function for fear-conditioned scan path speed', ...
 'responses, time-locked to the end of the CS-US interval.']};

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

% specific channel
chan_def_left         = cfg_const;
chan_def_left.name    = 'Last left eye';
chan_def_left.tag     = 'chan_def_left';
chan_def_left.val     = {'sps_l'};
chan_def_left.help    = {'Use the last sps channel from left eye.'};

chan_def_right         = cfg_const;
chan_def_right.name    = 'Last right eye';
chan_def_right.tag     = 'chan_def_right';
chan_def_right.val     = {'sps_r'};
chan_def_right.help    = {'Use the last sps channel from right eye.'};

best_eye                = cfg_const;
best_eye.name           = 'Best eye';
best_eye.tag            = 'best_eye';
best_eye.val            = {'sps'};
best_eye.help           = {'Use the sps data from the eye with fewest NaN values.'};

chan_def                = cfg_choice;
chan_def.name           = 'Default';
chan_def.tag            = 'chan_def';
chan_def.val            = {best_eye};
chan_def.values         = {best_eye, chan_def_left, chan_def_right};

a = cellfun(@(f) strcmpi(f.tag, 'chan'), glm_sps.val);
glm_sps.val{a}.values{1} = chan_def;
glm_sps.val{a}.val{1} = chan_def;
