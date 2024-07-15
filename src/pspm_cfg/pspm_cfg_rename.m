function rename = pspm_cfg_rename

%% Standard items
datafile         = pspm_cfg_selector_datafile;
newfilename      = pspm_cfg_selector_outputfile('New');

%% Specific items
%% Data file
filename         = datafile;
filename.help    = {'Choose name of original file.'};

%% Executable branch
rename      = cfg_exbranch;
rename.name = 'Rename File';
rename.tag  = 'rename';
rename.val  = {filename, newfilename};
rename.prog = @pspm_cfg_run_rename;
rename.vout = @pspm_cfg_vout_outfile;
rename.help = {'Rename PsPM data file. This renames the file and updates the file information.'};