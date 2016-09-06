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

%% SOA
soa         = cfg_entry;
soa.name    = 'SOA';
soa.tag     = 'soa';
soa.help    = {['Specify custom SOA for response function. Tested values are 3.5s, 4s and 6s. Default: 3.5s']};
soa.strtype = 'r';
soa.num     = [1 1];
soa.val     = {3.5};

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

rf        = cfg_choice;
rf.name   = 'Function';
rf.tag    = 'rf';
rf.val    = {hprf_fc{2}};
rf.values = {hprf_fc{:}};

bf        = cfg_branch;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {rf, soa};
bf.help   = {['Basis functions.']};

% look for bf and replace
b = cellfun(@(f) strcmpi(f.tag, 'bf'), glm_hp_fc.val);
glm_hp_fc.val{b} = bf;
