function export = pspm_cfg_export

%% Initialise
global settings

%% Standard items
outfile           = pspm_cfg_selector_outputfile();
modelfile         = pspm_cfg_selector_datafile('model', inf);

%% Specific items
% Screen
screen         = cfg_const;
screen.name    = 'Screen';
screen.tag     = 'screen';
screen.val     = {'screen'};
screen.help    = {''};

% Target
target         = cfg_choice;
target.name    = 'Target';
target.tag     = 'target';
target.values  = {screen, outfile};
target.help    = {'Export to screen or to file?'};

% Datatype
datatype        = cfg_menu;
datatype.name   = 'Stats type to export';
datatype.tag    = 'datatype';
datatype.val    = {'param'};
datatype.labels = {'All parameters','One parameter per condition','Reconstructed amplitude estimate'};
datatype.values = {'param','cond','recon'};
datatype.help   = pspm_cfg_help_format('pspm_export', 'options.statstype');

%Exclude conditions with too many NaN
exclude_missing         = cfg_menu;
exclude_missing.name    = 'Exclude conditions with too many NaN';
exclude_missing.tag     = 'exclude_missing';
exclude_missing.val     = {false};
exclude_missing.labels  = {'No', 'Yes'};
exclude_missing.values  = {false, true};
exclude_missing.help    = pspm_cfg_help_format('pspm_export', 'options.exclude_missing');

% Delimiter
tab         = cfg_const;
tab.name    = 'Tab';
tab.tag     = 'tab';
tab.val     = {'\t'};
tab.help    = {''};

newline         = cfg_const;
newline.name    = 'New Line';
newline.tag     = 'newline';
newline.val     = {'\n'};
newline.help    = {''};

semicolon         = cfg_const;
semicolon.name    = 'Semicolon';
semicolon.tag     = 'semicolon';
semicolon.val     = {';'};
semicolon.help    = {''};

comma         = cfg_const;
comma.name    = 'Comma';
comma.tag     = 'comma';
comma.val     = {','};
comma.help    = {''};

userspec         = cfg_entry;
userspec.name    = 'User Specific Delimiter';
userspec.tag     = 'userspec';
userspec.strtype = 's';
userspec.help    = {''};

delim        = cfg_choice;
delim.name   = 'Specify Delimiter for Output File';
delim.tag    = 'delim';
delim.val    = {tab,};
delim.values = {tab,newline,semicolon,comma,userspec};
delim.help   =  {''};


%% Executable Branch
export      = cfg_exbranch;
export.name = 'Export Statistics';
export.tag  = 'export';
export.val  = {modelfile, datatype, exclude_missing, target, delim};
export.prog = @pspm_cfg_run_export;
export.vout = @pspm_cfg_vout_outfile;
export.help = pspm_cfg_help_format('pspm_export');
