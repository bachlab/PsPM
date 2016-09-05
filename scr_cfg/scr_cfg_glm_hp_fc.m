function [glm_hp_fc] = scr_cfg_glm_hp_fc
% GLM HP FC

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

% set variables

vars = struct();
vars.modality = 'HPR';
vars.modspec = 'hp_fc';
vars.glmref = { ...
        ['Castegnetti, Tzovara, Staib, Paulus, Hofer & Bach (2016) ', ...
        '(Development of the GLM for fear-conditioned HPR)'] ...
    };
vars.glmhelp = '';

% load default settings
glm_hp_fc = scr_cfg_glm(vars);

% set correct name
glm_hp_fc.name = 'GLM for HP (fear-conditioning)';
glm_hp_fc.tag = 'glm_hp_fc';

% set callback function
glm_hp_fc.prog = @scr_cfg_run_glm_hp_fc;

%% Basis function
% HPRF
hprf_fc = cell(1, 2);
for i=1:2
    hprf_fc{i}        = cfg_const;
    hprf_fc{i}.name   = ['HPRF_FC ' num2str(i-1)];
    hprf_fc{i}.tag    = ['hprf_fc' num2str(i-1)];
    hprf_fc{i}.val    = {i-1};
end
hprf_fc{1}.help   = {'HPRF_FC without derivatives.'};
hprf_fc{2}.help   = {'HPRF_FC with time derivative (default).'};

bf        = cfg_choice;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {hprf_fc{2}};
bf.values = {hprf_fc{:}};
bf.help   = {['Basis functions. Standard is to use a canonical heart period response function ' ...
    ' for fear conditioning (HPRF_FC) with time derivative for later reconstruction of the response peak.']};

% look for bf and replace
b = cellfun(@(f) strcmpi(f.tag, 'bf'), glm_hp_fc.val);
glm_hp_fc.val{b} = bf;
