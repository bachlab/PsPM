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
extrapolate.help   = pspm_cfg_help_format('pspm_interpolate', 'options.extrapolate');

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
wm.help           = {['Specify whether to work on all channels in a file, or just ', ...
    'on the specified channel.']};

%% Executable branch
interpolate_data      = cfg_exbranch;
interpolate_data.name = 'Interpolate missing data';
interpolate_data.tag  = 'interpolate';
interpolate_data.val  = {datafile, extrapolate, wm};
interpolate_data.prog = @pspm_cfg_run_interpolate;
interpolate_data.vout = @pspm_cfg_vout_interpolate;
interpolate_data.help = pspm_cfg_help_format('pspm_interpolate');

function vout = pspm_cfg_vout_interpolate(job)
if isfield(job.mode, 'file')
    vout = pspm_cfg_vout_outfile;
elseif isfield(job.mode, 'channel')
    vout = pspm_cfg_vout_outchannel;
end