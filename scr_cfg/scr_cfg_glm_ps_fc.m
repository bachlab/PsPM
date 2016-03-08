function [glm_ps_fc] = scr_cfg_glm_ps_fc
% GLM PS FC

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

% set variables

vars = struct();
vars.modality = 'PSR';
vars.modspec = 'ps_fc';
vars.glmref = {};
vars.glmhelp = '';

% load default settings
glm_ps_fc = scr_cfg_glm(vars);

% set correct name
glm_ps_fc.name = 'GLM for PS (fear-conditioning)';
glm_ps_fc.tag = 'glm_ps_fc';

% set callback function
glm_ps_fc.prog = @scr_cfg_run_glm_ps_fc;

%% Basis function
% HPRF
psrf_fc = cell(1, 2);
for i=1:2
    psrf_fc{i}        = cfg_const;
    psrf_fc{i}.name   = ['PSRF_FC ' num2str(i-1)];
    psrf_fc{i}.tag    = ['psrf_fc' num2str(i-1)];
    psrf_fc{i}.val    = {i-1};
end
psrf_fc{1}.help   = {'PSRF_FC without derivatives.'};
psrf_fc{2}.help   = {'PSRF_FC with time derivative (default).'};

bf        = cfg_choice;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {psrf_fc{2}};
bf.values = {psrf_fc{:}};
bf.help   = {['Basis functions. Standard is to use a canonical pupil size response function ' ...
    ' for fear conditioning (PSRF_FC) with time derivative for later reconstruction of the response peak.']};

% look for bf and replace
b = cellfun(@(f) strcmpi(f.tag, 'bf'), glm_ps_fc.val);
glm_ps_fc.val{b} = bf;