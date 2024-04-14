function rename = pspm_cfg_rename

% $Id$
% $Rev$

%% Data file
filename         = cfg_files;
filename.name    = 'File Name';
filename.tag     = 'filename';
filename.num     = [1 1];
filename.filter  = '\.mat$';
filename.help    = {'Choose name of original file.'};

newfilename         = cfg_entry;
newfilename.name    = 'New File Name';
newfilename.tag     = 'newfilename';
newfilename.strtype = 's';
newfilename.num     = [1 1];
newfilename.help    = {''};

file         = cfg_branch;
file.name    = 'File';
file.tag     = 'file';
file.val     = {filename,newfilename};
file.help    = {''};

%% Executable branch
rename      = cfg_exbranch;
rename.name = 'Rename File';
rename.tag  = 'rename';
rename.val  = {filename, newfilename};
rename.prog = @pspm_cfg_run_rename;
rename.vout = @pspm_cfg_vout_rename;
rename.help = {'Rename PsPM data file. This renames the file and updates the file information.'};

function vout = pspm_cfg_vout_rename(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
