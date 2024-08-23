function [pp_gaze_convert] = pspm_cfg_gaze_convert
% function [pp_gaze_convert] = pspm_cfg_data_convert(job)
%
% Matlabbatch function for conversion functions of data
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)
% PsPM 5.1.2
% Updated 2021 Teddy Chao (WCHN, UCL)

%% Standard items
datafile         = pspm_cfg_selector_datafile;
chan             = pspm_cfg_selector_channel('gaze');
chan_action      = pspm_cfg_selector_channel_action;

%% width
width = cfg_entry;
width.name = 'Screen width';
width.tag = 'screen_width';
width.strtype = 'r';
width.num = [1 1];
width.val = {NaN};
width.help = pspm_cfg_help_format('pspm_convert_gaze', 'conversion.screen_width');

%% height
height = cfg_entry;
height.name = 'Screen height';
height.tag = 'screen_height';
height.strtype = 'r';
height.num = [1 1];
height.val = {NaN};
height.help = pspm_cfg_help_format('pspm_convert_gaze', 'conversion.screen_height');

%% screen distance (Only needed if unit degree is chosen)
screen_distance = cfg_entry;
screen_distance.name = 'Screen distance';
screen_distance.tag = 'screen_distance';
screen_distance.strtype = 'r';
screen_distance.num = [1 1];
screen_distance.val = {NaN};
screen_distance.help = pspm_cfg_help_format('pspm_convert_gaze', 'conversion.screen_distance');

%% From
from         = cfg_menu;
from.name    = 'From channel unit';
from.tag     = 'from';
from.values  = { 'pixel', 'mm', 'cm', 'm', 'inches', 'degree'};
from.labels  = { 'pixel', 'mm', 'cm', 'm', 'inches', 'degree' };
from.val     = {'mm'};
from.help    = pspm_cfg_help_format('pspm_convert_gaze', 'conversion.from');

%% Target
target         = cfg_menu;
target.name    = 'To channel unit';
target.tag     = 'target';
target.values  = { 'pixel', 'mm', 'cm', 'm', 'inches', 'degree', 'sps'};
target.labels  = { 'pixel', 'mm', 'cm', 'm', 'inches', 'degree' 'Scan path speed (degree/s)'};
target.val     = {'mm'};
target.help    = pspm_cfg_help_format('pspm_convert_gaze', 'conversion.target');

%% Executable branch
pp_gaze_convert        = cfg_exbranch;
pp_gaze_convert.name   = 'Gaze convert';
pp_gaze_convert.tag    = 'gaze_convert';
pp_gaze_convert.val    = {datafile, width, height, screen_distance, from, target, chan, chan_action};
pp_gaze_convert.prog   = @pspm_cfg_run_gaze_convert;
pp_gaze_convert.vout   = @pspm_cfg_vout_outchannel;
pp_gaze_convert.help   = pspm_cfg_help_format('pspm_convert_gaze');
