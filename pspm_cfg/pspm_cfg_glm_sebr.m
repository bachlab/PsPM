function [glm_seb] = pspm_cfg_glm_sebr
% GLM SEB FC

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end;

% set variables

vars = struct();
vars.modality = 'SEBR';
vars.modspec = 'sebr';
vars.glmref = { ...
        ['Khemka, Tzovara, Gerster, Quednow & Bach (2016) Psychophysiology'] ...
    };
vars.glmhelp = '';

% load default settings
glm_seb = pspm_cfg_glm(vars);

% set correct name
glm_seb.name = 'GLM for SEBR';
glm_seb.tag = 'glm_sebr';

% set callback function
glm_seb.prog = @pspm_cfg_run_glm_sebr;

%% Basis function
% SEBRF
sebrf = cell(1, 2);
for i=1:2
    sebrf{i}        = cfg_const;
    sebrf{i}.name   = ['SEBRF ' num2str(i-1)];
    sebrf{i}.tag    = ['sebrf' num2str(i-1)];
    sebrf{i}.val    = {i-1};
end
sebrf{1}.help   = {'SEBRF without derivatives (default).'};
sebrf{2}.help   = {'SEBRF with time derivative.'};

rf        = cfg_choice;
rf.name   = 'Function';
rf.tag    = 'rf';
rf.val    = {sebrf{1}};
rf.values = {sebrf{:}};

bf        = cfg_branch;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {rf};
bf.help   = {['Basis functions.']};

% look for bf and replace
b = cellfun(@(f) strcmpi(f.tag, 'bf'), glm_seb.val);
glm_seb.val{b} = bf;

% find latency and make it visible
lat = cellfun(@(f) strcmpi(f.tag, 'latency'), glm_seb.val);
glm_seb.val{lat}.hidden = false;

% also set free latency as default
free_lat = cellfun(@(f) strcmpi(f.tag, 'free'), glm_seb.val{lat}.values);
glm_seb.val{lat}.val = {glm_seb.val{lat}.values{free_lat}};
