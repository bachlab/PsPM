function [glm_rfr_e] = scr_cfg_glm_rfr_e
% GLM RFR E

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

% set variables

vars = struct();
vars.modality = 'RFRR';
vars.modspec = 'rfr_e';
vars.glmref = {};
vars.glmhelp = '';

% load default settings
glm_rfr_e = scr_cfg_glm(vars);

% set correct name
glm_rfr_e.name = 'GLM for RFR (evoked)';
glm_rfr_e.tag = 'glm_rfr_e';

% set callback function
glm_rfr_e.prog = @scr_cfg_run_glm_rfr_e;

%% Basis function
% PSRF
rfrrf_e = cell(1, 2);
for i=1:2
    rfrrf_e{i}        = cfg_const;
    rfrrf_e{i}.name   = ['RFRRF_E ' num2str(i-1)];
    rfrrf_e{i}.tag    = ['rfrrf_e' num2str(i-1)];
    rfrrf_e{i}.val    = {i};
end
rfrrf_e{1}.help   = {'RFRRF_E early and late response (default).'};
rfrrf_e{2}.help   = {'RFRRF_E early response with derivative.'};


bf        = cfg_choice;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {rfrrf_e{1}};
bf.values = {rfrrf_e{:}};
bf.help   = {['Basis functions. Standard is to use a canonical respiration amplitude response function ' ...
    ' for fear conditioning (RFRRF_E) with early and late response for later reconstruction.']};

% look for bf and replace
b = cellfun(@(f) strcmpi(f.tag, 'bf'), glm_rfr_e.val);
glm_rfr_e.val{b} = bf;