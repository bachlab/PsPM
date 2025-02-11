function ecg_editor = pspm_cfg_ecg_editor
%% Standard items
datafile         = pspm_cfg_selector_datafile;
ecg_chan         = pspm_cfg_selector_channel('ECG');
hb_chan         =  pspm_cfg_selector_channel('Heart beat');
artefact_file   = pspm_cfg_selector_datafile('artefact epochs');

%% Specific items
ecg_chan.name         = 'ECG channel';
ecg_chan.tag          = 'ecg_chan';
hb_chan.name          = 'Heart beat channel';
hb_chan.tag           = 'hb_chan';

%% artefact none
artefact_none         = cfg_const;
artefact_none.name    = 'None';
artefact_none.tag     = 'artefact_none';
artefact_none.val     = {0};
artefact_none.help    = {''};

%% Artefact epochs
artefact_epochs       = cfg_choice;
artefact_epochs.name  = 'Artefact epochs';
artefact_epochs.tag   = 'artefact_epochs';
artefact_epochs.val   = {artefact_none};
artefact_epochs.values = {artefact_none, artefact_file};
artefact_epochs.help   = pspm_cfg_help_format('pspm_ecg_editor', 'options.missing');

%% Upper limit
ulim                = cfg_entry;
ulim.name          = 'Upper limit';
ulim.tag            = 'upper';
ulim.strtype        = 'i';
ulim.num            = [1 1];
ulim.val            = {120};
ulim.help           = {};


%% Lower limit
llim                = cfg_entry;
llim.name          = 'Lower limit';
llim.tag            = 'lower';
llim.strtype        = 'i';
llim.num            = [1 1];
llim.val            = {40};
llim.help           = {};

%% Limits
lim                 = cfg_branch;
lim.name            = 'Limit';
lim.tag             = 'limit';
lim.val             = {ulim, llim};
lim.help            = pspm_cfg_help_format('pspm_ecg_editor', 'options.limits');

%% Factor
factor              = cfg_entry;
factor.name         = 'Factor';
factor.tag          = 'factor';
factor.strtype      = 'r';
factor.num          = [1 1];
factor.val          = {2};
factor.help         = pspm_cfg_help_format('pspm_ecg_editor', 'options.factor');

%% Faulty detection
faulty_settings     = cfg_branch;
faulty_settings.name = 'Faulty detection settings';
faulty_settings.tag  = 'faulty_settings';
faulty_settings.val  = {factor, lim};
faulty_settings.help = {};


%% Executable branch
ecg_editor      = cfg_exbranch;
ecg_editor.name = 'ECG editor';
ecg_editor.tag  = 'ecg_editor';
ecg_editor.val  = {datafile, ecg_chan, hb_chan, artefact_epochs, faulty_settings};
ecg_editor.prog = @pspm_cfg_run_ecg_editor;
ecg_editor.help = pspm_cfg_help_format('pspm_ecg_editor');
