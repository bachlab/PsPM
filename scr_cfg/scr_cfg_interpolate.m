function interpolate_data = scr_cfg_interpolate

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

%% Select file
datafile         = cfg_files;
datafile.name    = 'Data File(s)';
datafile.tag     = 'datafiles';
datafile.num     = [1 Inf];
datafile.help    = {'Select data file.'};


%% Overwrite file
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite existing file';
overwrite.tag     = 'overwrite';
overwrite.val     = {false};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {false, true};
overwrite.help    = {'Overwrite existing file?'};


%% Executable branch
interpolate_data      = cfg_exbranch;
interpolate_data.name = 'Interpolate missing data';
interpolate_data.tag  = 'interpolate';
interpolate_data.val  = {datafile, overwrite};
interpolate_data.prog = @scr_cfg_run_interpolate;
interpolate_data.vout = @scr_cfg_vout_interpolate;
interpolate_data.help = {['The function interpolates missing values. ', ...
    'The function works either on all continuous channels in the ', ...
    'specified PsPM data file and writes them to a new file with the ', ...
    'same name prepended by an ‘i’. Or only a specific channel is ', ...
    'interpolated and written to a new channel.']};

function vout = scr_cfg_vout_interpolate(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});