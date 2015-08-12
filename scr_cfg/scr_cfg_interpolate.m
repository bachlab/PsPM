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
datafile.help    = {'Select data file.'};

%% Filter

no_limit              = cfg_const;
no_limit.name         = 'No limit';
no_limit.tag          = 'nolimit';
no_limit.val          = {NaN};

ulim_manual           = cfg_entry;
ulim_manual.name      = 'Specify upper limit';
ulim_manual.tag       = 'ulim';
ulim_manual.strtype   = 'i';
ulim_manual.num       = [1 1];

llim_manual           = cfg_entry;
llim_manual.name      = 'Specify lower limit';
llim_manual.tag       = 'llim';
llim_manual.strtype   = 'i';
llim_manual.num       = [1 1];

ulim                  = cfg_choice;
ulim.name             = 'Upper Limit';
ulim.tag              = 'ulim';
ulim.val              = {no_limit};
ulim.values           = {no_limit, ulim_manual};

llim                  = cfg_choice;
llim.name             = 'Lower Limit';
llim.tag              = 'llim';
llim.val              = {no_limit};
llim.values           = {no_limit, llim_manual};

filter         = cfg_branch;
filter.name    = 'Filter';
filter.tag     = 'filter';
filter.val     = {ulim, llim};
filter.help    = {['Specify when data should be treated as ''missing''', ...
    ' and therefore be interpolated.']};

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
interpolate_data.val  = {datafile, filter, overwrite};
interpolate_data.prog = @scr_cfg_run_interpolate;
interpolate_data.vout = @scr_cfg_vout_interpolate;
interpolate_data.help = {['Try to interpolate, where no data is present.']};

function vout = scr_cfg_vout_interpolate(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});