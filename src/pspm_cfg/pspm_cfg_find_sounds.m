function [find_sounds] = pspm_cfg_find_sounds
% function [find_sounds] = pspm_cfg_find_sounds
%
% Matlabbatch function specifies the pspm_cfg_find_sounds.
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

%% Standard items
datafile         = pspm_cfg_selector_datafile;
chan             = pspm_cfg_selector_channel('sound');
chan_action      = pspm_cfg_selector_channel_action;
marker_chan      = pspm_cfg_selector_channel('marker');

%% Threshold
threshold            = cfg_entry;
threshold.name    = 'Threshold';
threshold.tag     = 'threshold';
threshold.strtype = 'r';
threshold.num     = [1 1];
threshold.val     = {0.1};
threshold.help    = pspm_cfg_help_format('pspm_find_sounds', 'options.threshold');

%% Region
region                 = cfg_entry;
region.name            = 'Region';
region.tag             = 'region';
region.help            = {''};
region.strtype         = 'r';
region.num             = [1 2];

%% Whole region
whole               = cfg_const;
whole.name          = 'Whole file';
whole.tag           = 'whole';
whole.val           = {0};

%% Region of interest
roi                 = cfg_choice;
roi.name            = 'Region of interest';
roi.tag             = 'roi';
roi.val             = {whole};
roi.values          = {whole, region};
roi.help            = pspm_cfg_help_format('pspm_find_sounds', 'options.roi');

%% Text only
text_only       = cfg_const;
text_only.name  = 'Text only';
text_only.tag   = 'text';
text_only.val   = {1};
text_only.help  = {};

%% Plot
hist_plot       = cfg_const;
hist_plot.name  = 'Histogram & Plot';
hist_plot.tag   = 'hist_plot';
hist_plot.val   = {2};
hist_plot.help    = pspm_cfg_help_format('pspm_find_sounds', 'options.plot');

%% Diagnostics output
diag_output        = cfg_choice;
diag_output.name   = 'Diagnostics output';
diag_output.tag    = 'diag_output';
diag_output.val    = {text_only};
diag_output.values = {text_only, hist_plot};
diag_output.help   = {''};

%% no
no                 = cfg_const;
no.name            = 'No';
no.tag             = 'no';
no.val             = {0};
no.help            = {''};

%% yes
yes                = cfg_const;
yes.name           = 'Yes';
yes.tag            = 'yes';
yes.val            = {1};
yes.help           = {''};

%% New corrected channel
new_corrected_chan         = cfg_choice;
new_corrected_chan.name    = 'Output specific sounds only';
new_corrected_chan.tag     = 'create_corrected_chan';
new_corrected_chan.val     = {no};
new_corrected_chan.values  = {no, yes};
new_corrected_chan.help    = pspm_cfg_help_format('pspm_find_sounds', 'options.channel_output');

%% Max delay
max_delay        = cfg_entry;
max_delay.name   = 'Max delay';
max_delay.tag    = 'max_delay';
max_delay.strtype = 'r';
max_delay.num    = [1 1];
max_delay.val    = {3};
max_delay.help   = pspm_cfg_help_format('pspm_find_sounds', 'options.maxdelay');

%% Min delay
min_delay        = cfg_entry;
min_delay.name   = 'Min delay';
min_delay.tag    = 'min_delay';
min_delay.strtype = 'r';
min_delay.num    = [1 1];
min_delay.val    = {0};
min_delay.help   = pspm_cfg_help_format('pspm_find_sounds', 'options.mindelay');

%% Expected sound count
n_sounds        = cfg_entry;
n_sounds.name   = 'Expected sound count';
n_sounds.tag    = 'n_sounds';
n_sounds.strtype = 'i';
n_sounds.num    = [1 1];
n_sounds.val    = {0};
n_sounds.help   = pspm_cfg_help_format('pspm_find_sounds', 'options.expectedSoundCount');

%% Diagnostics: which ones?
diag_yes = cfg_branch;
diag_yes.name = 'Yes';
diag_yes.tag    = 'diagnostics';
diag_yes.val = {diag_output, new_corrected_chan, marker_chan, max_delay, ...
    min_delay, n_sounds};
diag_yes.help = {};

%% Diagnostics
diagnostic        = cfg_choice;
diagnostic.name   = 'Diagnostic';
diagnostic.tag    = 'diagnostic';
diagnostic.val    = {no};
diagnostic.values = {diag_yes, no};
diagnostic.help   = pspm_cfg_help_format('pspm_find_sounds', 'options.diagnostics');


%% Executable branch
find_sounds      = cfg_exbranch;
find_sounds.name = 'Find startle sound onsets';
find_sounds.tag  = 'find_sounds';
find_sounds.val  = {datafile, chan, chan_action, threshold, roi, diagnostic};
find_sounds.prog = @pspm_cfg_run_find_sounds;
find_sounds.vout = @pspm_cfg_vout_outchannel;
find_sounds.help = pspm_cfg_help_format('pspm_find_sounds');
