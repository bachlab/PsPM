function [pp_pupil_gaze_convert] = pspm_cfg_data_convert
% function [pp_pupil_gaze_convert] = pspm_cfg_data_convert(job)
%
% Matlabbatch function for conversion functions of data
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id: pspm_cfg_data_convert.m 635 2019-03-14 10:14:50Z lciernik $
% $Rev: 635 $

% Initialise
global settings
if isempty(settings), pspm_init; end

%% Datafile
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
datafile.help    = {['Specify the PsPM datafile containing the channels ', ...
    'to be converted.'],' ',settings.datafilehelp};

%% Channel
channel             = cfg_entry;
channel.name        = 'Channel';
channel.tag         = 'channel';
channel.strtype     = 'i';
channel.num         = [1 Inf];
channel.help        = {['Specify the channel which should be converted.', ...
    'If 0, functions are executed on all channels.']};


%% width
width = cfg_entry;
width.name = 'Width';
width.tag = 'width';
width.strtype = 'r';
width.num = [1 1];
width.help = {['Width of the display window. Unit is `mm` if `degree` is chosen, ',...
                'otherwise `unit`.']};

%% height
height = cfg_entry;
height.name = 'Height';
height.tag = 'height';
height.strtype = 'r';
height.num = [1 1];
height.help = {['Height of the display window. Unit is `mm` if `degree` is chosen, ',...
                'otherwise `unit`.']};

%% screen distance (Only needed if unit degree is chosen)
distance = cfg_entry;
distance.name = 'Screen distance';
distance.tag = 'distance';
distance.strtype = 'r';
distance.num = [1 1];
distance.val = {-1};
distance.help = {['Distance between eye and screen in length units. ',...
                  'Unit is ''mm'' if ''degree'' is chosen. For other ',...
                  'conversions this field is ignored,i.e default value ''-1''.']};


%% From
from         = cfg_menu;
from.name    = 'From';
from.tag     = 'from';
from.values  = { 'pixel', 'mm', 'cm', 'm', 'inches', 'degree'};
from.labels  = { 'pixel', 'mm', 'cm', 'm', 'inches', 'degree'};
from.val     = {'mm'};
from.help    = {'Unit into which the measurements should be converted from.'};

%% To
to         = cfg_menu;
to.name    = 'to';
to.tag     = 'to';
to.values  = {'mm', 'cm', 'm', 'inches', 'degree', 'sps'};
to.labels  = {'mm', 'cm', 'm', 'inches', 'degree', 'scan path speed'};
to.val     = {'mm'};
to.help    = {'Unit into which the measurements should convert to.'};

%% Conversion
conversion          = cfg_branch;
conversion.name     = 'Conversion';
conversion.tag      = 'conversion';
conversion.val      = {channel, width, height, distance, from, to};
conversion.help     = {['Choose channel and conversion information']};

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
pp_pupil_gaze_convert        = cfg_exbranch;
pp_pupil_gaze_convert.name   = 'Pupil gaze convert';
pp_pupil_gaze_convert.tag    = 'pupil_gaze_convert';
pp_pupil_gaze_convert.val    = {datafile, conversions, chan_action};
pp_pupil_gaze_convert.prog   = @pspm_cfg_run_pupil_gaze_convert;
pp_pupil_gaze_convert.help   = {['Provides conversion functions for the specified ', ...
    'data (e.g. pupil gaze data).']};