function [glm_ra_e] = pspm_cfg_glm_ra_e
% GLM RA E

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end;

% set variables

vars = struct();
vars.modality = 'RAR';
vars.modspec = 'ra_e';
vars.glmref = {['Bach, Gerster, Tzovara, & Castegnetti (2016) ', ...
    'Psychophysiology (Development of the GLM evoked RAR)']};
vars.glmhelp = '';

% load default settings
glm_ra_e = pspm_cfg_glm(vars);

% set correct name
glm_ra_e.name = 'GLM for RA (evoked)';
glm_ra_e.tag = 'glm_ra_e';

% set callback function
glm_ra_e.prog = @pspm_cfg_run_glm_ra_e;

%% Basis function
% RARF
rarf_e = cell(1, 2);
for i=1:2
    rarf_e{i}        = cfg_const;
    rarf_e{i}.name   = ['RARF_E ' num2str(i-1)];
    rarf_e{i}.tag    = ['rarf_e' num2str(i-1)];
    rarf_e{i}.val    = {i-1};
end
rarf_e{1}.help   = {'RARF_E without time derivative.'};
rarf_e{2}.help   = {'RARF_E with time derivative (default).'};

bf        = cfg_choice;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {rarf_e{2}};
bf.values = {rarf_e{:}};
bf.help   = {['Basis functions.']};

% look for bf and replace
b = cellfun(@(f) strcmpi(f.tag, 'bf'), glm_ra_e.val);
glm_ra_e.val{b} = bf;
