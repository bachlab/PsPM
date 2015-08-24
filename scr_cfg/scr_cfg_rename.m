function rename = scr_cfg_rename

% $Id$
% $Rev$

%% Data file
filename         = cfg_files;
filename.name    = 'File Name';
filename.tag     = 'filename';
filename.num     = [1 1];
%filename.filter  = '\.mat$';
filename.help    = {'Choose name of original file.'};

newfilename         = cfg_entry;
newfilename.name    = 'New File Name';
newfilename.tag     = 'newfilename';
newfilename.strtype = 's';
%newfilename.num     = [1 1];
newfilename.help    = {''};

file         = cfg_branch;
file.name    = 'File';
file.tag     = 'file';
file.val     = {filename,newfilename};
file.help    = {''};

rename_file         = cfg_repeat;
rename_file.name    = 'Rename';
rename_file.tag     = 'rename_file';
rename_file.values  = {file};
rename_file.help    = {'Choose how many files to rename.'};

%% Executable branch
rename      = cfg_exbranch;
rename.name = 'Rename File';
rename.tag  = 'rename';
rename.val  = {rename_file};
rename.prog = @scr_cfg_run_rename;
rename.vout = @scr_cfg_vout_rename;
rename.help = {'Rename PsPM data file. This renames the file and updates the file information.'};

function vout = scr_cfg_vout_rename(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
