function interpolate_data = scr_cfg_interpolate

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

%% Select file
datafile         = cfg_files;
datafile.name    = 'Data File(s)';
datafile.tag     = 'datafile';
datafile.num     = [1 Inf];
datafile.help    = {'Select datafile.'};

%% Overwrite file
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite Existing File';
overwrite.tag     = 'overwrite';
overwrite.val     = {false};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {false, true};
overwrite.help    = {'Overwrite existing file?'};


%% Executable branch
interpolate_data      = cfg_exbranch;
interpolate_data.name = 'Interpolate';
interpolate_data.tag  = 'interploate';
interpolate_data.val  = {datafile,overwrite};
interpolate_data.prog = @scr_cfg_run_interpolate;
interpolate_data.vout = @scr_cfg_vout_interpolate;
interpolate_data.help = {['Try to interpolate, where no data is present.']};

function vout = scr_cfg_vout_interpolate(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});