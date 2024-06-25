function split_sessions = pspm_cfg_split_sessions
% Updated 11-03-2024 by Teddy

%% Standard items
datafile         = pspm_cfg_selector_datafile;
channel          = pspm_cfg_selector_channel('marker');
overwrite        = pspm_cfg_selector_overwrite;

%% Specific items

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
split_manual.help   = {'Split sessions according to given marker id''s.'};

%% Split behaviour
split_behavior         = cfg_choice;
split_behavior.name    = 'Split behavior';
split_behavior.tag     = 'split_behavior';
split_behavior.values  = {split_auto, split_manual};
split_behavior.val     = {split_auto};
split_behavior.help    = {['Choose whether sessions should be detected ', ...
'automatically or if sessions should be split according to ', ...
'given marker id''s.']};

%% Missing epochs
miss_epoch_false          = cfg_const;
miss_epoch_false.name     = 'No missing epochs file';
miss_epoch_false.tag      = 'no';
miss_epoch_false.val      = {0};
miss_epoch_false.help     = {'No missing epochs file to be processed.'};

miss_epoch_true          = cfg_files;
miss_epoch_true.name     = 'Add missing epochs file';
miss_epoch_true.tag      = 'name';
miss_epoch_true.num      = [1 1];
miss_epoch_true.help     = {['The selected missing epochs file will be ',...
'split as well.'], ['The input must be the name of a file containing missing ',...
'epochs in seconds.']};

missing_epoch         = cfg_choice;
missing_epoch.name    = 'Missing epoch';
missing_epoch.tag     = 'missing_epochs_file';
missing_epoch.values  = {miss_epoch_false, miss_epoch_true};
missing_epoch.val     = {miss_epoch_false};
missing_epoch.help = {['A missing epochs file can be added here '...
'and will be split in the same way as the PsPM data file. '...
'Split sessions can handle up to one missing epoch file.']};

%% Executable branch
split_sessions      = cfg_exbranch;
split_sessions.name = 'Split Sessions';
split_sessions.tag  = 'split_sessions';
split_sessions.val  = {datafile,channel,split_behavior,missing_epoch,overwrite};
split_sessions.prog = @pspm_cfg_run_split_sessions;
split_sessions.vout = @pspm_cfg_vout_outfile;
split_sessions.help = pspm_cfg_help_format('pspm_split_sessions');

