function [pp_pupil_size_convert] = pspm_cfg_pupil_size_convert
% function [pp_pupil_size_convert] = pspm_cfg_pupil_size_convert(job)
%
% Matlabbatch function for pupil size conversion
%__________________________________________________________________________
% PsPM 4.3
% (C) 2016 Sam Maxwell (University College London)


% Initialise
global settings

%% Datafile
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
datafile.help    = {['Specify the PsPM datafile containing the channels ', ...
    'to be converted.'],' ',settings.datafilehelp};

%% Channel
channel             = pspm_cfg_channel_selector('pupil_both');

%% area2diameter
area2diameter       = cfg_const;
area2diameter.name  = 'Area to diameter';
area2diameter.tag   = 'area2diameter';
area2diameter.val   = {'area2diameter'};
area2diameter.help  = {['']};
               
%% Mode
mode                = cfg_choice;
mode.name           = 'Mode';
mode.tag            = 'mode';
mode.val            = {area2diameter};
mode.values         = {area2diameter};
mode.help           = {['Choose conversion mode.']};

%% Conversion
conversion          = cfg_branch;
conversion.name     = 'Conversion';
conversion.tag      = 'conversion';
conversion.val      = {channel, mode};
conversion.help     = {['']};

%% Conversions
conversions         = cfg_repeat;
conversions.name    = 'Conversion list';
conversions.tag     = 'conversions';
conversions.values  = {conversion};
conversions.num     = [1 Inf];
conversion.help     = {['']};

%% Channel action
chan_action         = cfg_menu;
chan_action.name    = 'Channel action';
chan_action.tag     = 'channel_action';
chan_action.val     = {'add'};
chan_action.values  = {'replace', 'add'};
chan_action.labels  = {'Replace channel', 'Add channel'};
chan_action.help    = {['Choose whether to ''replace'' the given channel ', ... 
    'or ''add'' the converted data as a new channel.']};

%% Executable branch
pp_pupil_size_convert        = cfg_exbranch;
pp_pupil_size_convert.name   = 'Pupil size convert';
pp_pupil_size_convert.tag    = 'pupil_size_convert';
pp_pupil_size_convert.val    = {datafile, conversion, chan_action};
pp_pupil_size_convert.prog   = @pspm_cfg_run_pupil_size_convert;
pp_pupil_size_convert.help   = {['Provides conversion functions for the specified ', ...
    'data (e.g. pupil size data). Currently only area to diameter conversion is ',...
    'available.']};