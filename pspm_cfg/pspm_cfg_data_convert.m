function [pp_convert] = pspm_cfg__data_convert
% function [pp_convert] = pspm_cfg_data_convert(job)
%
% Matlabbatch function for conversion functions of data
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end

%% Datafile
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
datafile.help    = {['Specify the PsPM datafile containing the channels ', ...
    'to be converted.']};

%% Channel
channel             = cfg_entry;
channel.name        = 'Channel';
channel.tag         = 'channel';
channel.strtype     = 'i';
channel.num         = [1 1];
channel.help        = {['Specify the channel which should be converted.']};

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
chan_action.val     = {'replace'};
chan_action.values  = {'replace', 'add'};
chan_action.labels  = {'Replace channel', 'Add channel'};
chan_action.help    = {['Choose whether to ''replace'' the given channel ', ... 
    'or ''add'' the converted data as a new channel.']};

%% Executable branch
pp_convert        = cfg_exbranch;
pp_convert.name   = 'Convert data';
pp_convert.tag    = 'convert_data';
pp_convert.val    = {datafile, conversions, chan_action};
pp_convert.prog   = @pspm_cfg_run_data_convert;
pp_convert.help   = {['Provides conversion functions for the specified ', ...
    'data (e.g. pupil data). Currently only area to diameter conversion is ',...
    'available.']};
