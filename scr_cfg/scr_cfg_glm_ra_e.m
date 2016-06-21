function [glm_ra_e] = scr_cfg_glm_ra_e
% GLM RA E

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

% set variables

vars = struct();
vars.modality = 'RAR';
vars.modspec = 'ra_e';
vars.glmref = {};
vars.glmhelp = '';

% load default settings
glm_ra_e = scr_cfg_glm(vars);

% set correct name
glm_ra_e.name = 'GLM for RA (evoked)';
glm_ra_e.tag = 'glm_ra_e';

% set callback function
glm_ra_e.prog = @scr_cfg_run_glm_ra_e;

%% Basis function
% PSRF
rarf_e = cell(1, 2);
for i=1:2
    rarf_e{i}        = cfg_const;
    rarf_e{i}.name   = ['RARF_E ' num2str(i-1)];
    rarf_e{i}.tag    = ['rarf_e' num2str(i-1)];
    rarf_e{i}.val    = {i};
end
rarf_e{1}.help   = {'RARF_E early and late response (default).'};
rarf_e{2}.help   = {'RARF_E early response with derivative.'};


bf        = cfg_choice;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {rarf_e{1}};
bf.values = {rarf_e{:}};
bf.help   = {['Basis functions. Standard is to use a canonical respiration amplitude response function ' ...
    ' for fear conditioning (RARF_E) with early and late response for later reconstruction.']};

% look for bf and replace
b = cellfun(@(f) strcmpi(f.tag, 'bf'), glm_ra_e.val);
glm_ra_e.val{b} = bf;