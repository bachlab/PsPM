function combine_markerchannels = pspm_cfg_combine_markerchannels
% ● Description
%   function [combine_markerchannels] = pspm_cfg_combine_markerchannels(job)
%   Matlab UI function for pspm_combine_markerchannels
% ● History
%   PsPM 6.2
%   Written in 2023 by Teddy Chao

%% Standard items
datafile         = pspm_cfg_selector_datafile;
marker_chan      = pspm_cfg_selector_channel('many');
channel_action   = pspm_cfg_selector_channel_action;

%% Specific items
marker_chan.help    = {['Choose any number of marker channel numbers ',...
                           'to combine. If 0, all marker ',...
                           'channels in the file are combined.']};

%% Executable branch
combine_markerchannels        = cfg_exbranch;
combine_markerchannels.name   = 'Combine marker channels';
combine_markerchannels.tag    = 'combine_markerchannels';
combine_markerchannels.val    = {datafile, channel_action, marker_chan};
combine_markerchannels.prog   = @pspm_cfg_run_combine_markerchannels;
combine_markerchannels.vout   = @pspm_cfg_vout_combine_markerchannels;
combine_markerchannels.help   = {['The feature combine marker channels ',...
  'can combine all the marker channels of a data file and add the ',...
  'result to the original data file, specified by channel action.']};

function vout = pspm_cfg_vout_combine_markerchannels(job)
vout = cfg_dep;
vout.sname      = 'Output Channel';
vout.src_output = substruct('()',{1});


