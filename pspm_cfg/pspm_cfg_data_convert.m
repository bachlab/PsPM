function [pp_convert] = pspm_cfg_data_convert
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
    'to be converted.'],' ',settings.datafilehelp};

%% Channel
channel             = cfg_entry;
channel.name        = 'Channel';
channel.tag         = 'channel';
channel.strtype     = 'i';
channel.num         = [1 Inf];
channel.help        = {['Specify the channel which should be converted.', ...
    'If 0, functions are executed on all channels.']};

%% area2diameter
area2diameter       = cfg_const;
area2diameter.name  = 'Area to diameter';
area2diameter.tag   = 'area2diameter';
area2diameter.val   = {'area2diameter'};
area2diameter.help  = {['']};

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

%% unit
unit         = cfg_menu;
unit.name    = 'Unit';
unit.tag     = 'unit';
unit.values  = {'mm', 'cm', 'm', 'inches','degree'};
unit.labels  = {'mm', 'cm', 'm', 'inches','degree'};
unit.val     = {'mm'};
unit.help    = {'Unit into which the measurements should be converted.'};

%% pixel2unit
pixel2unit = cfg_branch;
pixel2unit.name = 'Pixel to unit';
pixel2unit.tag = 'pixel2unit';
pixel2unit.val = {width, height,distance,unit};
pixel2unit.help = {['Convert pupil gaze coordinates from ', ...
                   'pixel values to unit values. The unit values',... ,
                   'can be length units or unit `degree`(i.e. visual angle). ',...
                   'In this case the data is first converted into length units ',...
                   'and afterwards into visual angles. ',...
                   'Visual angle is expressed in spherical coordinates.',...
                   'Length units are needed to validate ', ...
                   'fixations with degree visual angle.']};
               
%% Eyes
eyes                = cfg_menu;
eyes.name           = 'Eyes';
eyes.tag            = 'eyes';
eyes.val            = {'all'};
eyes.labels         = {'All eyes', 'Left eye', 'Right eye'};
eyes.values         = {'all', 'left', 'right'};
eyes.help           = {['Choose eyes which should be processed. If ''All', ...
    'eyes'' is selected, all eyes which are present in the data will ', ...
    'be processed. Otherwise only the chosen eye will be processed.']};

%% Visualangle to scanpath speed
visangle2sps        = cfg_branch;
visangle2sps.name   = 'Visualangle to scanpath speed';
visangle2sps.tag    = 'visangle2sps';
visangle2sps.val    = {eyes};
visangle2sps.help   = {['Takes paires of channels with gaze data in spherical',...
                       ' coordinates (i.e. visual angle) and computes scanpath speed',...
                       ' (i.e. scalar distance per second). Saves result into a ',...
                       'new channel with channeltype ''sps'' (scanpath speed)']};
               
%% Mode
mode                = cfg_choice;
mode.name           = 'Mode';
mode.tag            = 'mode';
mode.val            = {area2diameter};
mode.values         = {area2diameter, pixel2unit, visangle2sps};
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
