function glm_scr = scr_cfg_glm_scr
% GLM

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

% set variables

vars = struct();
vars.modality = 'SCR';
vars.modspec = 'SCR';
vars.glmref = { ...
        'Bach, Flandin, et al. (2009) Journal of Neuroscience Methods (Development of the SCR model)', ...
        'Bach, Flandin, et al. (2010) International Journal of Psychophysiology (Canonical SCR function)', ...
        'Bach, Friston & Dolan (2013) Psychophysiology (Improved algorithm)', ...
        'Bach (2014) Biological Psychology (Comparison with Ledalab)' ...
    };
vars.glmhelp = '';

% load default settings
glm_scr = scr_cfg_glm(vars);

% set callback function
glm_scr.prog = @scr_cfg_run_glm_scr;

% set correct name
glm_scr.name = 'GLM for SCR';
glm_scr.tag = 'glm_scr';


