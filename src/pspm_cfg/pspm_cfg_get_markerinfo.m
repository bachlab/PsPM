function markerinfo = pspm_cfg_get_markerinfo

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end

%% Data file
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 Inf];
%datafile.filter  = '\.(mat|MAT)$';
datafile.help    = {['Specify the PsPM datafile containing a marker channel ',...
                     'with a markerinfo field.'],' ',settings.datafilehelp};

%% Marker channel
mrk_chan         = pspm_cfg_channel_selector('marker');

%% file name
file_name        = cfg_entry;
file_name.name   = 'File name';
file_name.tag    = 'file_name';
file_name.strtype = 's';
file_name.num    = [1 Inf];
file_name.help   = {''};

%% file path
file_path        = cfg_files;
file_path.name   = 'File path';
file_path.tag    = 'file_path';
file_path.filter = 'dir';
file_path.num    = [1 1];
file_path.help   = {''};

%% file
file             = cfg_branch;
file.name        = 'File';
file.tag         = 'file';
file.val         = {file_name, file_path};
file.help        = {'Specify the output file to which the marker info should be written to.'};

%% Overwrite file
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite existing file';
overwrite.tag     = 'overwrite';
overwrite.val     = {false};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {false, true};
overwrite.help    = {'Overwrite existing marker info files?'};

%% Output
output           = cfg_branch;
output.name      = 'Output';
output.tag       = 'output';
output.val       = {file, overwrite};
output.help      = {''};

%% Executable branch
markerinfo      = cfg_exbranch;
markerinfo.name = 'Extract event marker info';
markerinfo.tag  = 'extract_markerinfo';
markerinfo.val  = {datafile, mrk_chan, output};
markerinfo.prog = @pspm_cfg_run_get_markerinfo;
markerinfo.vout = @pspm_cfg_vout_get_markerinfo;
markerinfo.help = {['Allows to extract additional marker information for ', ...
    'further processing. The information can be used to distinguish ', ...
    'between different types of events or for other purposes. This is ', ...
    'usually used to extract marker information from EEG-style data files ', ...
    'such as BrainVision or NeuroScan.']};

function vout = pspm_cfg_vout_get_markerinfo(job)
vout = cfg_dep;
vout.sname      = 'Output File(s)';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
