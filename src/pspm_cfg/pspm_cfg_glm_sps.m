function [glm_sps] = pspm_cfg_glm_sps
% * Description

%   This function applies to the glm model for the modality ScanPath
%   Speed (sps)
% * History
%   Updated in 2024 by Teddy

% Initialise

global settings
if isempty(settings)
    pspm_init;
end
%% Set variables
vars          = struct();
vars.modality = 'sps';

vars.modspec = 'sps';


% load default settings
glm_sps = pspm_cfg_glm(vars);

% set correct name
glm_sps.name = 'GLM for SPS (fear-conditioning)';
glm_sps.tag = 'glm_sps';

% set callback function
glm_sps.prog = @pspm_cfg_run_glm_sps;

%% SOA
soa           = cfg_entry;
soa.name      = 'SOA';
soa.tag       = 'soa';
soa.help      = {['Specify custom SOA for response function.', ...
                  'Tested values are 3.5 s and 4 s. ', ...
                  'Default: 3.5 s']};
soa.strtype   = 'r';
soa.num       = [1 1];
soa.val       = {3.5};
%% Basis function
% SPS
% bf = boxfunction
spsrf_box       = cfg_const;
spsrf_box.name  = 'Average scanpath speed';
spsrf_box.tag   = 'spsrf_box';
spsrf_box.val   = {'spsrf_box'};
spsrf_box.help  = {['This option implements a boxcar function over the SOA, and yields the average ',...
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
% rf function
rf        = cfg_choice;
rf.name   = 'Function';
rf.tag    = 'rf';
rf.val    = {spsrf_box};
rf.values = {spsrf_box,spsrf_gamma};
% basis function
bf        = cfg_branch;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {rf,soa};
bf.help   = {'Basis functions.'};
% look for bf and replace
b = cellfun(@(f) strcmpi(f.tag, 'bf'), glm_sps.val);
glm_sps.val{b} = bf;

