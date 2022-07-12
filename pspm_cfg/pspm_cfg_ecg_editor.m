function ecg_editor = pspm_cfg_ecg_editor

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end

%% Data file
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 Inf];
%datafile.filter  = '\.(mat|MAT)$';
datafile.help    = {'Specify the PsPM datafile containing the ECG data',...
                    ' ',settings.datafilehelp};

%% Default channel
chan_def         = cfg_const;
chan_def.name    = 'Default';
chan_def.tag     = 'chan_def';
chan_def.val     = {0};
chan_def.help    = {''};

%% chan none
chan_none         = cfg_const;
chan_none.name    = 'None';
chan_none.tag     = 'chan_none';
chan_none.val     = {0};
chan_none.help    = {''};

%% chan default
chan_nr         = cfg_entry;
chan_nr.name    = 'Number';
chan_nr.tag     = 'chan_nr';
chan_nr.strtype = 'i';
chan_nr.num     = [1 1];
chan_nr.help    = {''};

%% ecg chan
ecg_chan         = cfg_choice;
ecg_chan.name    = 'ECG Channel';
ecg_chan.tag     = 'ecg_chan';
ecg_chan.val     = {chan_def};
ecg_chan.values  = {chan_def, chan_nr};
ecg_chan.help    = {['Specify the channel containing the ECG data.']};

%% hb chan
hb_chan         = cfg_choice;
hb_chan.name    = 'HB Channel';
hb_chan.tag     = 'hb_chan';
hb_chan.val     = {chan_none};
hb_chan.values  = {chan_none, chan_nr};
hb_chan.help    = {['Specify the channel containing the HB data.']};

%% artefact none
artefact_none         = cfg_const;
artefact_none.name    = 'None';
artefact_none.tag     = 'artefact_none';
artefact_none.val     = {0};
artefact_none.help    = {''};

%% artefact file
artefact_file         = cfg_files;
artefact_file.name    = 'File';
artefact_file.tag     = 'artefact_file';
artefact_file.num     = [1 1];
artefact_file.help    = {['']};

%% Artefact epochs
artefact_epochs       = cfg_choice;
artefact_epochs.name  = 'Artefact epochs';
artefact_epochs.tag   = 'artefact_epochs';
artefact_epochs.val   = {artefact_none};
artefact_epochs.values = {artefact_none, artefact_file};
artefact_epochs.help  = {['Specify a PsPM timing file defining artefact epochs.']};

%% Upper limit
ulim                = cfg_entry;
ulim.name          = 'Upper limit';
ulim.tag            = 'upper';
ulim.strtype        = 'i';
ulim.num            = [1 1];
ulim.val            = {120};
ulim.help           = {['Values bigger than this value (in bpm) will be marked as faulty.']};


%% Lower limit
llim                = cfg_entry;
llim.name          = 'Lower limit';
llim.tag            = 'lower';
llim.strtype        = 'i';
llim.num            = [1 1];
llim.val            = {40};
llim.help           = {['Values smaller than this value (in bpm) will be marked as faulty.']};

%% Limits
lim                 = cfg_branch;
lim.name            = 'Limit';
lim.tag             = 'limit';
lim.val             = {ulim, llim};
lim.help            = {['Define hard limits for the faulty detection.']};

%% Factor
factor              = cfg_entry;
factor.name         = 'Factor';
factor.tag          = 'factor';
factor.strtype      = 'r';
factor.num          = [1 1];
factor.val          = {2};
factor.help         = {['The minimum factor potentially wrong QRS ', ...
    'complexes should deviate from the standard deviation.']};

%% Faulty detection
faulty_settings     = cfg_branch;
faulty_settings.name = 'Faulty detection settings';
faulty_settings.tag  = 'faulty_settings';
faulty_settings.val  = {factor, lim};
faulty_settings.help = {['Settings for the faulty detection.']};


%% Executable branch
ecg_editor      = cfg_exbranch;
ecg_editor.name = 'ECG editor';
ecg_editor.tag  = 'ecg_editor';
ecg_editor.val  = {datafile, ecg_chan, hb_chan, artefact_epochs, faulty_settings};
ecg_editor.prog = @pspm_cfg_run_ecg_editor;
ecg_editor.help = {['']};