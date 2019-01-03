function export = pspm_cfg_export
% Contrast (first level)

% $Id$
% $Rev$


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

% Parameter
param         = cfg_const;
param.name    = 'param';
param.tag     = 'param';
param.val     = {'param'};
param.help    = {''};

% exclude option
excl_op           = cfg_menu;
excl_op.name    = 'Exclude condtitions with too many NaN';
excl_op.tag     = 'excl_op';
excl_op.val     = {false};
excl_op.labels  = {'No', 'Yes'};
excl_op.values  = {false, true};
excl_op.help  ={['If you choose yes only statistics of conditions are ',...
                 'show which have a NaN-ration according to cutoff value, ',...
                 'which was introduced when creating the model. Otherwise ',...
                 'all statistics are shown.']};
% Condition
cond          =  cfg_branch;
cond.name     = 'cond';
cond.tag      = 'cond';
cond.val      = {excl_op};
cond.help     = {''};
% Reconstructed
recon         = cfg_const;
recon.name    = 'recon';
recon.tag     = 'recon';
recon.val     = {'recon'};
recon.help    = {''};

% Datatype
datatype        = cfg_choice;
datatype.name   = 'Stats type';
datatype.tag    = 'datatype';
datatype.values = {param,cond,recon};
datatype.help   = {['Normally, all parameter estimates are exported. For GLM, you can choose to ' ...
    'only export the first basis function per condition, or the reconstructed response per condition. ' ...
    'For DCM, you can specify contrasts based on conditions as well. This will average within conditions. ', ...
    'This argument cannot be used for other first-level models.'], ...
    '', ...
    '- Parameter: Export all parameter estimates.', '', ...
    ['- Condition: Export conditions in a GLM, automatically detects number ' ...
    'of basis functions and uses only the first one (i.e. without derivatives), ', ...
    'or export condition averages in DCM.'], '', ...
    ['- Reconstructed: Export all conditions in a GLM, reconstructs estimated response ' ...
    'from all basis functions and export the peak of the estimated response.'], ''};

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
export.val  = {modelfile, datatype, target, delim};
export.prog = @pspm_cfg_run_export;
export.help = {'Export statistics to a file for further analysis in statistical software, or to the screen.'};