function interpolate_data = pspm_cfg_interpolate

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end;

%% Select file
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafiles';
datafile.num     = [1 1];
datafile.help    = {'Select data file.',' ',settings.datafilehelp};

%% Extrapolate
extrapolate      = cfg_menu;
extrapolate.name = 'Extrapolate';
extrapolate.tag  = 'extrapolate';
extrapolate.val  = {false};
extrapolate.labels = {'Enabled','Disabled'};
extrapolate.values = {true, false};
extrapolate.help   = {['Enable extrapolation when trying to interpolate ', ...
    'NaN values at the edges of the data files.']};

%% Overwrite file
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite existing file';
overwrite.tag     = 'overwrite';
overwrite.val     = {false};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {false, true};
overwrite.help    = {'Choose "yes" if you want to overwrite existing file(s) with the same name.'};

%% File mode
fm                = cfg_branch;
fm.name           = 'File mode';
fm.tag            = 'file';
fm.help           = {''};
fm.val            = {overwrite};

%% Interpolate channels
src_chan          = pspm_cfg_channel_selector('any');

%% New channel
new_chan          = cfg_const;
new_chan.name     = 'New channel';
new_chan.tag      = 'new_chan';
new_chan.help     = {'Always add as a new channel.'};
new_chan.val      = {true};

%% Replace channel
replace_chan      = cfg_const;
replace_chan.name = 'Replace channel';
replace_chan.tag  = 'replace_chan';
replace_chan.help = {'Replace specified channel.'};
replace_chan.val  = {true};

%% Interpolated data mode
mode              = cfg_choice;
mode.name         = 'Mode';
mode.tag          = 'mode';
mode.help         = {'Specify what to do with the interpolated data.'};
mode.val          = {new_chan};
mode.values       = {new_chan, replace_chan};

%% Channel mode
cm                = cfg_branch;
cm.name           = 'Channel mode';
cm.tag            = 'channel';
cm.help           = {''};
cm.val            = {src_chan, mode};

%% Work mode
wm                = cfg_choice;
wm.name           = 'Work mode';
wm.tag            = 'mode';
wm.val            = {fm};
wm.values         = {fm, cm};
wm.help           = {['Specify whether to work on a whole file or just ', ...
    'on the specified channel. If whole file is specified, ', ...
    'the data will be written to a new file with the same name ', ...
    'prepended by an "i". Otherwise the specified channel(s) will be ', ...
    'written to a new channel or replace an ', ...
    'existing channel in the same file.']};

%% Executable branch
interpolate_data      = cfg_exbranch;
interpolate_data.name = 'Interpolate missing data';
interpolate_data.tag  = 'interpolate';
interpolate_data.val  = {datafile, extrapolate, wm};
interpolate_data.prog = @pspm_cfg_run_interpolate;
interpolate_data.vout = @pspm_cfg_vout_interpolate;
interpolate_data.help = {['The function interpolates missing values, ', ...
    'either for all continuous channels in a specified PsPM data ', ...
    'file (file mode), or for a selected channel only (channel mode). ', ...
    'In file mode, the function writes all channels to a new file with ', ...
    'the same name prepended by an "i". In channel mode, the function ', ...
    'interpolates data and either replaces a channel or ', ...
    'writes the data to a new channel.']};

function vout = pspm_cfg_vout_interpolate(job)

vout = cfg_dep;
if isfield(job.mode, 'file')
    vout.sname      = 'Output File';
    % this can be entered into any file selector
    vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
elseif isfield(job.mode, 'channel')
    vout.sname      = 'Interpolated channel';
    vout.tgt_spec   = cfg_findspec({{'class','cfg_entry', 'strtype', 'i'}});
end;
vout.src_output = substruct('()',{':'});
