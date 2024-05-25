function export = pspm_cfg_export

% Select File
modelfile         = cfg_files;
modelfile.name    = 'Model File(s)';
modelfile.tag     = 'modelfile';
modelfile.num     = [1 Inf];
modelfile.filter  = '.*\.(mat|MAT)$';
modelfile.help    = {'Specify file from which to export statistics.'};

% Screen
screen         = cfg_const;
screen.name    = 'Screen';
screen.tag     = 'screen';
screen.val     = {'screen'};
screen.help    = {''};

% Filename
filename         = cfg_entry;
filename.name    = 'Filename';
filename.tag     = 'filename';
filename.strtype = 's';
filename.help    = {'Specify a filename.'};

% Target
target         = cfg_choice;
target.name    = 'Target';
target.tag     = 'target';
target.values  = {screen, filename};
target.help    = {'Export to screen or to file?'};

% Datatype
datatype        = cfg_menu;
datatype.name   = 'Stats type to export';
datatype.tag    = 'datatype';
datatype.val    = {'param'};
datatype.labels = {'All parameters','One parameter per condition','Reconstructed amplitude estimate'};
datatype.values = {'param','cond','recon'};
datatype.help   = {['Normally, all parameter estimates are exported. For GLM, you can choose to ' ...
    'only export the first basis function per condition, or the reconstructed response per condition. ' ...
    'For DCM, you can specify contrasts based on conditions as well. This will average within conditions. ', ...
    'This argument cannot be used for other first-level models.'], ...
    '', ...
    '- All parameters: Export all parameter estimates.', '', ...
    ['- One parameter per condition: Export conditions in a GLM, automatically detects number ' ...
    'of basis functions and uses only the first one (i.e. without derivatives), ', ...
    'or export condition averages in DCM.'], '', ...
    ['- Reconstructed amplitude estimate: Export all conditions in a GLM, reconstructs estimated response ' ...
    'from all basis functions and export the peak amplitude of the estimated response.'], ''};

%Exclude conditions with too many NaN
exclude_missing         = cfg_menu;
exclude_missing.name    = 'Exclude condtitions with too many NaN';
exclude_missing.tag     = 'exclude_missing';
exclude_missing.val     = {false};
exclude_missing.labels  = {'No', 'Yes'};
exclude_missing.values  = {false, true};
exclude_missing.help  ={['Exclude parameters from conditions with too many NaN ',...
                 'values. This option can only be used for GLM file for ',...
                 'which the corresponding option was used during model ',...
                 'setup. Otherwise this argument is ignored.']};
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
export.help = {'Export statistics to a file for further analysis in statistical software, or to the screen.'};
