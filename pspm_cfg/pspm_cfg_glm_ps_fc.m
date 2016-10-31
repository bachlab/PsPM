function [glm_ps_fc] = pspm_cfg_glm_ps_fc
% GLM PS FC

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end;

% set variables

vars = struct();
vars.modality = 'PSR';
vars.modspec = 'ps_fc';
vars.glmref = { ...
        ['Christoph W. Korn, Matthias Staib, Athina Tzovara, ', ...
        'Giuseppe Castegnetti and Dominik R. Bach (under review) ', ...
        'A pupil size response model to assess fear learning'] ...
    };
vars.glmhelp = '';

% load default settings
glm_ps_fc = pspm_cfg_glm(vars);

% set correct name
glm_ps_fc.name = 'GLM for PS (fear-conditioning)';
glm_ps_fc.tag = 'glm_ps_fc';

% set callback function
glm_ps_fc.prog = @pspm_cfg_run_glm_ps_fc;

%% Basis function
% PSRF
psrf_fc = cell(1, 4);
for i=1:4
    psrf_fc{i}        = cfg_const;
    psrf_fc{i}.name   = ['PSRF_FC ' num2str(i-1)];
    psrf_fc{i}.tag    = ['psrf_fc' num2str(i-1)];
    psrf_fc{i}.val    = {i-1};
end
psrf_fc{1}.help   = {'PSRF_FC CS only and without derivatives.'};
psrf_fc{2}.help   = {'PSRF_FC CS and derivatives for CS (default).'};
psrf_fc{3}.help    = {'PSRF_FC with CS and US. Without derivatives.'};
psrf_fc{4}.help    = {'PSRF_FC with US only and without derivatives.'};

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

% specific channel
chan_def_left         = cfg_const;
chan_def_left.name    = 'Left eye default';
chan_def_left.tag     = 'chan_def_left';
chan_def_left.val     = {'pupil_l'};
chan_def_left.help    = {''};

chan_def_right         = cfg_const;
chan_def_right.name    = 'Right eye default';
chan_def_right.tag     = 'chan_def_right';
chan_def_right.val     = {'pupil_r'};
chan_def_right.help    = {''};

chan_def                = cfg_choice;
chan_def.name           = 'Default';
chan_def.tag            = 'chan_def';
chan_def.val            = {chan_def_left};
chan_def.values         = {chan_def_left, chan_def_right};

a = cellfun(@(f) strcmpi(f.tag, 'chan'), glm_ps_fc.val);
glm_ps_fc.val{a}.values{1} = chan_def;
glm_ps_fc.val{a}.val{1} = chan_def;
