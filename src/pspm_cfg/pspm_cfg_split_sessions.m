function split_sessions = pspm_cfg_split_sessions

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
datafile.help    = {settings.datafilehelp};

%% Marker channel
chan_def         = cfg_const;
chan_def.name    = 'Default';
chan_def.tag     = 'chan_def';
chan_def.val     = {0};
chan_def.help    = {''};

chan_nr         = cfg_entry;
chan_nr.name    = 'Number';
chan_nr.tag     = 'chan_nr';
chan_nr.strtype = 'i';
chan_nr.num     = [1 1];
chan_nr.help    = {''};

mrk_chan         = cfg_choice;
mrk_chan.name    = 'Marker Channel';
mrk_chan.tag     = 'mrk_chan';
mrk_chan.val     = {chan_def};
mrk_chan.values  = {chan_def, chan_nr};
mrk_chan.help    = {['If you have more than one marker channel, choose the marker ' ...
    'channel used for splitting sessions (default: use first marker channel).']};
%% split auto
split_auto          = cfg_const;
split_auto.name     = 'Automatic';
split_auto.tag      = 'auto';
split_auto.val      = {0};
split_auto.help     = {['Detect sessions according to longest distances ', ...
    'between markers.']};

%% split manual
split_manual        = cfg_entry;
split_manual.name   = 'Marker';
split_manual.tag    = 'marker';
split_manual.strtype = 'i';
split_manual.num    = [1 inf];
split_manual.help   = {['Split sessions according to given marker id''s.']};

%% Split behaviour
split_behavior         = cfg_choice;
split_behavior.name    = 'Split behavior';
split_behavior.tag     = 'split_behavior';
split_behavior.values  = {split_auto, split_manual};
split_behavior.val     = {split_auto};
split_behavior.help    = {['Choose whether sessions should be detected ', ...
    'automatically or if sessions should be split according to ', ...
    'given marker id''s.']};

%% Missing epoche files
missing      = cfg_files;
missing.name = 'Missing Epoch File';
missing.tag  = 'missing_epoch_file';
missing.num  = [1 Inf];
missing.help = {['Add missing epochs file for SCR data, which will ',...
    'be split. The input must be a filename containing missing ',...
    'epochs in seconds. ','Leave blank if not used.']};

%% missing switch file
%missing_switch         = cfg_choice;
%missing_switch.name    = 'Add missing epochs';
%missing_switch.tag     = 'add_missing_epochs';
%missing_switch.val     = {false};
%missing_switch.values  = {false, missing};
%missing_switch.values  = {missing};
%missing_switch.help    = {'test'};

options        = cfg_branch;
options.name   = 'Options';
options.tag    = 'options';
options.val    = {missing};
options.help   = {'Optional parameters'};

%% Overwrite file
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite Existing File';
overwrite.tag     = 'overwrite';
overwrite.val     = {false};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {false, true};
overwrite.help    = {'Overwrite existing file?'};


%% Executable branch
split_sessions      = cfg_exbranch;
split_sessions.name = 'Split Sessions';
split_sessions.tag  = 'split_sessions';
split_sessions.val  = {datafile,mrk_chan,split_behavior,options,overwrite};
split_sessions.prog = @pspm_cfg_run_split_sessions;
split_sessions.vout = @pspm_cfg_vout_split_sessions;
split_sessions.help = {['Split sessions, defined by trains of of markers. This function ' ...
    'is most commonly used to split fMRI sessions when a (slice or volume) pulse from the ' ...
    'MRI scanner has been recorded. The function will identify trains of markers and detect ' ...
    'breaks in these marker sequences. The individual sessions will be written to new files ' ...
    'with a suffix ''_sn'', and the session number. You can choose a marker channel if several were recorded.']};

% function vout = pspm_cfg_vout_split_sessions(job)
function vout = pspm_cfg_vout_split_sessions(job)
vout = cfg_dep;
vout.sname      = 'Output File(s)';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
