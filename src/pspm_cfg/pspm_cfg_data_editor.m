function data_editor = pspm_cfg_data_editor

%% Standard items
datafile               =  pspm_cfg_selector_datafile;
datafile.help          = {'Specify the PsPM datafile to be edited.'};
output                 = pspm_cfg_selector_outputfile('Editor output');
epochs                 = pspm_cfg_selector_datafile('epochs');

%% disabled
disabled            = cfg_const;
disabled.name       = 'Disabled';
disabled.tag        = 'disabled';
disabled.val        = {'disabled'};

%% epoch file
epochfile          = cfg_choice;
epochfile.name     = 'Epoch input';
epochfile.tag      = 'epochs';
epochfile.val      = {disabled};
epochfile.values   = {epochs, disabled};
epochfile.help     = {['Choose pre-defined epochs to be displayed and used in the data editor. Can also be provided manually in the data editor. ']};

%% enabled
%output.name        = 'Enabled';


%% output file
outputfile          = cfg_choice;
outputfile.name     = 'Epoch output';
outputfile.tag      = 'outputfile';
outputfile.val      = {disabled};
outputfile.values   = {output, disabled};
outputfile.help     = {['Choose a file to save the resulting epochs. Can also be provided manually in the data editor. ']};

%% Executable branch
data_editor      = cfg_exbranch;
data_editor.name = 'Data editor';
data_editor.tag  = 'data_editor';
data_editor.val  = {datafile, epochfile, outputfile};
data_editor.prog = @pspm_cfg_run_data_editor;
data_editor.help = pspm_cfg_help_format('pspm_data_editor');
