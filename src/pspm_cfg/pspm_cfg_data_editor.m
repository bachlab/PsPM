function data_editor = pspm_cfg_data_editor

%% Standard items
datafile               =  pspm_cfg_selector_datafile;
datafile.help          = {'Specify the PsPM datafile to be edited.'};
[file_name, file_path] = pspm_cfg_selector_outputfile('editor output');

%% enabled
enabled             = cfg_branch;
enabled.name        = 'Enabled';
enabled.tag         = 'enabled';
enabled.val         = {file_name, file_path};
enabled.help        = {'Specify an epoch file to which the editor output should be written to.'};

%% disabled
disabled            = cfg_const;
disabled.name       = 'Disabled';
disabled.tag        = 'disabled';
disabled.val        = {'disabled'};

%% output file
outputfile          = cfg_choice;
outputfile.name     = 'Output file';
outputfile.tag      = 'outputfile';
outputfile.val      = {disabled};
outputfile.values   = {enabled, disabled};
outputfile.help     = {['']};


%% Executable branch
data_editor      = cfg_exbranch;
data_editor.name = 'Data editor';
data_editor.tag  = 'data_editor';
data_editor.val  = {datafile, outputfile};
data_editor.prog = @pspm_cfg_run_data_editor;
data_editor.help = {['']};
