function [glm_ps_fc] = pspm_cfg_glm_ps_fc
% GLM PS FC

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end

% set variables

vars = struct();
vars.modality = 'PSR';
vars.modspec = 'ps_fc';
vars.glmref = { ...
        ['Korn, Staib, Tzovara, Castegnetti & Bach (2016) Psychophysiology ', ...
        '(Development of the GLM for fear-conditioned PSR)'] ...
    };
vars.glmhelp = ['Pupil size models were developed with pupil size data ', ...
    'recorded in diameter values. Therefore pupil size data analyzed ', ...
    'using these models should also be in diameter.'];

% load default settings
glm_ps_fc = pspm_cfg_glm(vars);

% set correct name
glm_ps_fc.name = 'GLM for PS (fear-conditioning)';
glm_ps_fc.tag = 'glm_ps_fc';

% set callback function
glm_ps_fc.prog = @pspm_cfg_run_glm_ps_fc;

%% Basis function
% PSRF
psrf_fc = cell(1, 5);
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

% add erlang response function
psrf_fc{5} = cfg_const;
psrf_fc{5}.name = 'PSRF_ERL';
psrf_fc{5}.tag = 'psrf_erl';
psrf_fc{5}.val = {4};
psrf_fc{5}.help = {'PSRF_ERL use a Erlang response funcation according to', ...
    ['Hoeks, B., & Levelt, W.J.M. (1993). Pupillary Dilation as a Measure ', ...
    'of Attention - a Quantitative System-Analysis. Behavior Research ', ...
    'Methods Instruments & Computers, 25, 16-26.']};

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
chan_def_left.name    = 'First left eye';
chan_def_left.tag     = 'chan_def_left';
chan_def_left.val     = {'pupil_l'};
chan_def_left.help    = {'Use first left eye channel.'};

chan_def_right         = cfg_const;
chan_def_right.name    = 'First right eye';
chan_def_right.tag     = 'chan_def_right';
chan_def_right.val     = {'pupil_r'};
chan_def_right.help    = {'Use first right eye channel.'};

best_eye                = cfg_const;
best_eye.name           = 'Best eye';
best_eye.tag            = 'best_eye';
best_eye.val            = {'pupil'};
best_eye.help           = {['Use eye with the fewest NaN values.']};

chan_def                = cfg_choice;
chan_def.name           = 'Default';
chan_def.tag            = 'chan_def';
chan_def.val            = {best_eye};
chan_def.values         = {best_eye, chan_def_left, chan_def_right};

a = cellfun(@(f) strcmpi(f.tag, 'chan'), glm_ps_fc.val);
glm_ps_fc.val{a}.values{1} = chan_def;
glm_ps_fc.val{a}.val{1} = chan_def;
