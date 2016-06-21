function [glm_rp_e] = scr_cfg_glm_rp_e
% GLM RP E

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

% set variables

vars = struct();
vars.modality = 'RPR';
vars.modspec = 'rp_e';
vars.glmref = {};
vars.glmhelp = '';

% load default settings
glm_rp_e = scr_cfg_glm(vars);

% set correct name
glm_rp_e.name = 'GLM for RP (evoked)';
glm_rp_e.tag = 'glm_rp_e';

% set callback function
glm_rp_e.prog = @scr_cfg_run_glm_rp_e;

%% Basis function
% PSRF
rprf_e = cell(1, 2);
for i=1:2
    rprf_e{i}        = cfg_const;
    rprf_e{i}.name   = ['RPRF_E ' num2str(i-1)];
    rprf_e{i}.tag    = ['rprf_e' num2str(i-1)];
    rprf_e{i}.val    = {i};
end
rprf_e{1}.help   = {'RPRF_E early and late response (default).'};
rprf_e{2}.help   = {'RPRF_E early response with derivative.'};


bf        = cfg_choice;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {rprf_e{1}};
bf.values = {rprf_e{:}};
bf.help   = {['Basis functions. Standard is to use a canonical respiration amplitude response function ' ...
    ' for fear conditioning (RARF_E) with early and late response for later reconstruction.']};

% look for bf and replace
b = cellfun(@(f) strcmpi(f.tag, 'bf'), glm_rp_e.val);
glm_rp_e.val{b} = bf;