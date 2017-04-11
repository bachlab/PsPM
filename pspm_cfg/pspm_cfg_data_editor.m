function data_editor = pspm_cfg_data_editor

% $Id$
% $Rev$

%% Data file
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 Inf];
%datafile.filter  = '\.(mat|MAT)$';
datafile.help    = {'Specify the PsPM datafile to be edited.'};

%% file name
file_name        = cfg_entry;
file_name.name   = 'File name';
file_name.tag    = 'file_name';
file_name.strtype = 's';
file_name.num    = [1 Inf];
file_name.help   = {''};

%% file path
file_path        = cfg_files;
file_path.name   = 'File path';
file_path.tag    = 'file_path';
file_path.filter = 'dir';
file_path.num    = [1 1];
file_path.help   = {''};

%% enabled
enabled             = cfg_branch;
enabled.name        = 'Enabled';
enabled.tag         = 'enabled';
enabled.val         = {file_name, file_path};
enabled.help        = {'Specify the output file to which the editor output should be written to.'};

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