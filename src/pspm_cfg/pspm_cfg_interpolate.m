function interpolate_data = pspm_cfg_interpolate

%% Standard items
datafile          = pspm_cfg_selector_datafile;
src_chan          = pspm_cfg_selector_channel('any');
channel_action    = pspm_cfg_selector_channel_action;
overwrite         = pspm_cfg_selector_overwrite;
 
%% Extrapolate
extrapolate      = cfg_menu;
extrapolate.name = 'Extrapolate';
extrapolate.tag  = 'extrapolate';
extrapolate.val  = {false};
extrapolate.labels = {'Enabled','Disabled'};
extrapolate.values = {true, false};
extrapolate.help   = {['Enable extrapolation when trying to interpolate ', ...
    'NaN values at the edges of the data files.']};

%% File mode
fm                = cfg_branch;
fm.name           = 'File mode';
fm.tag            = 'file';
fm.help           = {''};
fm.val            = {overwrite};

%% Channel mode
cm                = cfg_branch;
cm.name           = 'Channel mode';
cm.tag            = 'channel';
cm.help           = {''};
cm.val            = {src_chan, channel_action};

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
if isfield(job.mode, 'file')
    vout = pspm_cfg_vout_outfile;
elseif isfield(job.mode, 'channel')
    vout = pspm_cfg_vout_outchannel;
end