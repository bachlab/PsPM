function tam = pspm_cfg_tam

global settings
if isempty(settings), pspm_init; end

%% Standard items
output      = pspm_cfg_selector_outputfile('Model');
session_rep = pspm_cfg_selector_data_design('tam');
timeunits   = pspm_cfg_selector_timeunits;
chan        = pspm_cfg_selector_channel('pupil');
normalise   = pspm_cfg_selector_norm;

filter_default = settings.tam(1).filter;

if ischar(filter_default.lpfreq) && strcmpi(filter_default.lpfreq, 'none')
    filter_default.lpfreq = NaN;
end

if ischar(filter_default.hpfreq) && strcmpi(filter_default.hpfreq, 'none')
    filter_default.hpfreq = NaN;
end

if ischar(filter_default.down) && strcmpi(filter_default.down, 'none')
    filter_default.down = NaN;
end

filter = pspm_cfg_selector_filter(filter_default);

%% Model specification
modelspec         = cfg_menu;
modelspec.name    = 'Model';
modelspec.tag     = 'modelspec';
modelspec.labels  = {'Dilation', 'Constriction'};
modelspec.values  = {'dilation', 'constriction'};
modelspec.val     = {'dilation'};
modelspec.help    = pspm_cfg_help_format('pspm_tam', 'model.modelspec');

%% Window
window         = cfg_entry;
window.name    = 'Window';
window.tag     = 'window';
window.strtype = 'r';
window.num     = [1 1];
window.help    = pspm_cfg_help_format('pspm_tam', 'model.window');

%% Baseline
baseline         = cfg_entry;
baseline.name    = 'Baseline';
baseline.tag     = 'baseline';
baseline.strtype = 'r';
baseline.num     = [1 1];
baseline.val     = {0};
baseline.help    = pspm_cfg_help_format('pspm_tam', 'model.baseline');

%% Normalize maximum
norm_max         = cfg_menu;
norm_max.name    = 'Normalize maximum';
norm_max.tag     = 'norm_max';
norm_max.labels  = {'No', 'Yes'};
norm_max.values  = {0, 1};
norm_max.val     = {0};
norm_max.help    = pspm_cfg_help_format('pspm_tam', 'model.norm_max');

%% Standard experimental condition
std_none         = cfg_const;
std_none.name    = 'None';
std_none.tag     = 'none';
std_none.val     = {'none'};

std_name         = cfg_entry;
std_name.name    = 'Condition name';
std_name.tag     = 'name';
std_name.strtype = 's';

std_index         = cfg_entry;
std_index.name    = 'Condition index';
std_index.tag     = 'index';
std_index.strtype = 'i';
std_index.num     = [1 1];

std_exp_cond        = cfg_choice;
std_exp_cond.name   = 'Standard experimental condition';
std_exp_cond.tag    = 'std_exp_cond';
std_exp_cond.val    = {std_none};
std_exp_cond.values = {std_none, std_name, std_index};
std_exp_cond.help   = pspm_cfg_help_format('pspm_tam', 'model.std_exp_cond');

%% Executable branch
tam       = cfg_exbranch;
tam.name  = 'Trial Average Model';
tam.tag   = 'tam';
tam.val   = {output, chan, timeunits, session_rep, modelspec, window, normalise, filter, baseline, norm_max, std_exp_cond};
tam.prog  = @pspm_cfg_run_tam;
tam.vout  = @pspm_cfg_vout_outfile;
tam.help  = pspm_cfg_help_format('pspm_tam');