function [pp_gaze_convert] = pspm_cfg_gaze_convert
% function [pp_gaze_convert] = pspm_cfg_data_convert(job)
%
% Matlabbatch function for conversion functions of data
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id: pspm_cfg_gaze_convert.m 635 2019-03-14 10:14:50Z lciernik $
% $Rev: 635 $

% Initialise
global settings
%if isempty(settings), pspm_init; end

%% Datafile
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
datafile.help    = {['Specify the PsPM datafile containing the channels ', ...
    'to be converted.'],' ',settings.datafilehelp};


%% width
width = cfg_entry;
width.name = 'Width';
width.tag = 'width';
width.strtype = 'r';
width.num = [1 1];
width.help = {['Width of the display window. Unit is `mm`.']};

%% height
height = cfg_entry;
height.name = 'Height';
height.tag = 'height';
height.strtype = 'r';
height.num = [1 1];
height.help = {['Height of the display window. Unit is `mm`.']};

%% screen distance (Only needed if unit degree is chosen)
screen_distance = cfg_entry;
screen_distance.name = 'Screen distance';
screen_distance.tag = 'screen_distance';
screen_distance.strtype = 'r';
screen_distance.num = [1 1];
screen_distance.val = {-1};
screen_distance.help = {['Distance between eye and screen. Unit is `mm` ']};


%% From
from         = cfg_menu;
from.name    = 'From distance unit';
from.tag     = 'from';
from.values  = { 'pixel', 'mm', 'cm', 'm', 'inches' };
from.labels  = { 'pixel', 'mm', 'cm', 'm', 'inches' };
from.val     = {'mm'};
from.help    = {'Distance unit from which the measurements should be converted.'};


%% Conversions
distance2sps         = cfg_branch;
distance2sps.name    = 'Distance to scan path speed conversion';
distance2sps.tag     = 'distance2sps';
distance2sps.val     = {width, height, screen_distance, from };
distance2sps.help    = {['Choose conversion information']};

distance2degree         = cfg_branch;
distance2degree.name    = 'Distance to degree conversion';
distance2degree.tag     = 'distance2degree';
distance2degree.val     = {width, height, screen_distance, from };
distance2degree.help    = {['Choose conversion information']};

%% Eyes
eyes                = cfg_menu;
eyes.name           = 'Eyes';
eyes.tag            = 'eyes';
eyes.val            = {'all'};
eyes.labels         = {'All eyes', 'Left eye', 'Right eye'};
eyes.values         = {'lr', 'l', 'r'};
eyes.help           = {['Choose eyes which should be processed. If ''All', ...
    'eyes'' is selected, all eyes which are present in the data will ', ...
    'be processed. Otherwise only the chosen eye will be processed.']};

degree2sps         = cfg_branch;
degree2sps.name    = 'Degree to scan path speed conversion';
degree2sps.tag     = 'degree2sps';
degree2sps.val     = {eyes};
degree2sps.help    = {['Convert degree gaze data to scan path speed.', ...
'This conversion will find the degree unit gaze data from the file automatically.', ...
'The gaze data must not contain any NaN values.']};

%% unit
unit         = cfg_menu;
unit.name    = 'Unit';
unit.tag     = 'unit';
unit.values  = {'mm', 'cm', 'm', 'inches'};
unit.labels  = {'mm', 'cm', 'm', 'inches'};
unit.val     = {'mm'};
unit.help    = {'Unit into which the measurements should be converted.'};

%% Channel
channel             = cfg_entry;
channel.name        = 'Channel';
channel.tag         = 'channel';
channel.strtype     = 'i';
channel.num         = [1 Inf];
channel.help        = {['Specify the channel which should be converted.', ...
    'If 0, conversion will be attmepted on all channels']};

pixel2unit = cfg_branch;
pixel2unit.name = 'Pixel to unit';
pixel2unit.tag = 'pixel2unit';
pixel2unit.val = {width, height,screen_distance,unit, channel};
pixel2unit.help = {['Convert pupil gaze coordinates from pixel values ',...
                    'to distance unit values']};


%% Conversions
conversion         = cfg_choice;
conversion.name    = 'Conversion Type';
conversion.tag     = 'conversion';
conversion.val     = {distance2degree};
conversion.values  = {distance2degree, distance2sps, degree2sps,pixel2unit };
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
pp_gaze_convert        = cfg_exbranch;
pp_gaze_convert.name   = 'Gaze convert';
pp_gaze_convert.tag    = 'gaze_convert';
pp_gaze_convert.val    = {datafile, conversion, chan_action};
pp_gaze_convert.prog   = @pspm_cfg_run_gaze_convert;
pp_gaze_convert.help   = {['Provides conversion functions for the specified ', ...
    'data (e.g. gaze data).']};
