function combine_markerchannels = pspm_cfg_combine_markerchannels
% ● Description
%   function [pp_convert] = pspm_cfg_combine_markerchannels(job)
%   Matlab UI function for pspm_combine_markerchannels
% ● History
%   PsPM 6.2
%   Written in 2023 by Teddy Chao

%% Initialise
global settings
if isempty(settings), pspm_init; end

%% Datafile
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
datafile.help    = {['Specify the PsPM datafile containing the channels ', ...
  'to be converted.'],' ',settings.datafilehelp};

% Channel action
channel_action         = cfg_menu;
channel_action.name    = 'Channel Action';
channel_action.tag     = 'channel_action';
channel_action.val     = {'add'};
channel_action.labels  = {'Add', 'Replace'};
channel_action.values  = {'add', 'replace'};
channel_action.help    = {['Specify whether the new channel should be added ',...
                          'on top of existing marker channels (add), or ',...
                          'all existing marker channels should be deleted ',...
                          'and replaced with the one new channel (replace).']};

% Specific marker channel
marker_chan_num         = cfg_entry;
marker_chan_num.name    = 'Marker channel number';
marker_chan_num.tag     = 'marker_chan_num';
marker_chan_num.strtype = 'i';
marker_chan_num.num     = [1 1];
marker_chan_num.help    = {['Choose any number of marker channel numbers ',...
                           'to combine. If undefined or 0, all marker ',...
                           'channels of each file are combined.']};

% Marker chan
marker_chan         = cfg_menu;
marker_chan.name    = 'Marker channels';
marker_chan.tag     = 'marker_chan_num';
marker_chan.val     = {0};
marker_chan.labels  = {'All', 'Specific channels'};
marker_chan.values  = {0, marker_chan_num};
marker_chan.help    = {['Choose any number of marker channel numbers ',...
                           'to combine. If undefined or 0, all marker ',...
                           'channels of each file are combined.']};

%% Executable branch
combine_markerchannels        = cfg_exbranch;
combine_markerchannels.name   = 'Combine marker channels';
combine_markerchannels.tag    = 'combine_markerchannels';
combine_markerchannels.val    = {datafile, channel_action, marker_chan};
combine_markerchannels.prog   = @pspm_cfg_run_combine_markerchannels;
combine_markerchannels.help   = {['The feature combine marker channels ',...
  'can combine all the marker channels of a data file and add the ',...
  'result to the original data file, specified by channel action.']};
