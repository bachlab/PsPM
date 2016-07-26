function data_editor = scr_cfg_data_editor

% $Id$
% $Rev$

%% Data file
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 Inf];
%datafile.filter  = '\.(mat|MAT)$';
datafile.help    = {'Specify the PsPM datafile to be edited.'};


%% Executable branch
data_editor      = cfg_exbranch;
data_editor.name = 'Data editor';
data_editor.tag  = 'data_editor';
data_editor.val  = {datafile};
data_editor.prog = @scr_cfg_run_data_editor;
data_editor.help = {['']};