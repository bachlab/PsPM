function [glm_hp_rew] = pspm_cfg_glm_hp_rew
% GLM HP FC

% Initialise
global settings
if isempty(settings), pspm_init; end;

% set variables

vars = struct();
vars.modality = 'HPR';
vars.modspec = 'hp_fc';
vars.glmref = { ...
        ['Xia Y, Liu H, Kälin OK, Gerster S, Bach DR (under review). Measuring', ...
         'human Pavlovian appetitive conditioning and memory retention.']};
vars.glmhelp = '';

% load default settings
glm_hp_rew = pspm_cfg_glm(vars);

% set correct name
glm_hp_rew.name = 'GLM for HP (reward-conditioning)';
glm_hp_rew.tag = 'glm_hp_rew';

% set callback function
glm_hp_rew.prog = @pspm_cfg_run_glm_hp_rew;

%% Basis function
% HPRF
hprf_rew        = cfg_const;
hprf_rew.name   = 'HPRF for reward conditioning';
hprf_rew.tag    = 'hprf_rew';
hprf_rew.val    = {1};
hprf_rew.help   = {'HPRF for reward conditioning without derivatives.'};

rf        = cfg_choice;
rf.name   = 'Function';
rf.tag    = 'rf';
rf.val    = {hprf_rew};
rf.values = {hprf_rew};

bf        = cfg_branch;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {rf};
bf.help   = {['Basis functions.']};

% look for bf and replace
b = cellfun(@(f) strcmpi(f.tag, 'bf'), glm_hp_rew.val);
glm_hp_rew.val{b} = bf;
