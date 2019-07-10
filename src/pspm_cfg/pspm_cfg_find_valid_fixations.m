function [find_valid_fixations] = pspm_cfg_find_valid_fixations(job)
% function [find_valid_fixations] = pspm_cfg_find_valid_fixations(job) 
% Matlabbatch function for pspm_find_valid_fixations
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id: pspm_cfg_find_valid_fixations.m 635 2019-03-14 10:14:50Z lciernik $
% $Rev: 635 $

% Initialise
global settings
if isempty(settings), pspm_init; end

%% Data file
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 Inf];
datafile.help    = {['Specify the PsPM datafile containing the gaze ', ...
    ' recordings in length units.'],' ',settings.datafilehelp};

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

%% Visual angle
box_degree                      = cfg_entry;
box_degree.name                 = 'Visual angle';
box_degree.tag                  = 'box_degree';
box_degree.strtype              = 'i';
box_degree.num                  = [1 1];
box_degree.help                 = {['Range of valid fixations (around a ', ...
    'fixation point). The value has to be in degree visual angle.']};

%% Distance
distance                      = cfg_entry;
distance.name                 = 'Distance';
distance.tag                  = 'distance';
distance.strtype              = 'r';
distance.num                  = [1 1];
distance.help                 = {['Distance between eyes and screen in ', ...
    'length units.']};

%% unit
unit                      = cfg_menu;
unit.name                 = 'Unit';
unit.tag                  = 'unit';
unit.values               = {'mm', 'cm', 'm', 'inches'};
unit.labels               = {'mm', 'cm', 'm', 'inches'};
unit.val                  = {'mm'};
unit.help                 = {'Unit in which the distance is given'};


%% Resolution
resolution                      = cfg_entry;
resolution.name                 = 'Resolution';
resolution.tag                  = 'resolution';
resolution.strtype              = 'i';
resolution.num                  = [1 2];
resolution.val                  = {[1280 1024]};
resolution.help                 = {['Resolution to which the fixation ', ...
    'point refers (maximum value of the x- and y-coordinates). This can ', ...
    'be the resolution set in cogent / psychtoolbox (e.g. [1280 1024]) ', ...
    'or the width and height of the screen in length values (e.g. [50 40]).']};


%% Default (fixation point)
fixpoint_default                = cfg_const;
fixpoint_default.name           = 'Default';
fixpoint_default.tag            = 'default';
fixpoint_default.val            = {1};
fixpoint_default.help           = {['If default is set, the middle of the ', ...
    'screen will be defined as fixation point.']};

%% File
fixpoint_file         = cfg_files;
fixpoint_file.name    = 'File';
fixpoint_file.tag     = 'fixpoint_file';
fixpoint_file.num     = [1 1];
fixpoint_file.help    = {['.mat file containing a variable F with an ', ...
    'n x 2 matrix. N should have the length of the recorded data and each ', ...
    'row should define the fixation point for the respective ', ...
    'recorded data row.']};

%% Point
fixpoint                = cfg_entry;
fixpoint.name           = 'Point';
fixpoint.tag            = 'fixpoint';
fixpoint.strtype        = 'r';
fixpoint.num            = [1 2];
fixpoint.help           = {['If the fixation point does not change ', ...
    'during the acquisition, specify x- and y-coordinates of the ', ...
    'constant fixation point.']};

%% Fixation point
fixation_point                      = cfg_choice;
fixation_point.name                 = 'Fixation point';
fixation_point.tag                  = 'fixation_point';
fixation_point.val                  = {fixpoint_default};
fixation_point.values               = {fixpoint_default, fixpoint_file, ...
    fixpoint};
fixation_point.help                 = {['X- and y-coordinates for the point',...
    'of fixation with respect to the given resolution.']};


%% Validate fixations
validation_settings        = cfg_branch;
validation_settings.name   = 'Validation settings';
validation_settings.tag    = 'validation_settings';
validation_settings.val    = {box_degree, distance, unit, resolution, fixation_point};
validation_settings.help   = {['Settings to validate fixations within a ', ...
    'given range on the screen (in degree visual angle).']};

%% Validate on bitmap
bitmap         = cfg_files;
bitmap.name    = 'Bitmap file';
bitmap.tag     = 'bitmap_file';
bitmap.num     = [1 1];
bitmap.help    = {['.mat file containing a variable bitmap with an n x m ',...
                   'matrix. The matrix bitmap represents the display ',...
                   '(n = height and m = width) and holds for each position ',...
                   'a 1, where a gaze point is valid, and a 0 otherwise.',... 
                   'Gaze data at invalid positions (indicated by bitmap or ',...
                   'outside the display) are set to NaN.']};

%% Validation method

val_method        = cfg_choice;
val_method.name   = 'Validation method';
val_method.tag    = 'val_method';
val_method.values = {validation_settings,bitmap};
val_method.help   = {['You can either validate the data by indicating a ',...
                      'range on the screen (in degree visual angle) and ',...
                      'fixation point(s) or by passing a bitmap representing ',... 
                      'the screen and holding a 1 for all the fixations ',...
                      'that are valid.']};
%% Channels
channels                    = cfg_entry;
channels.name               = 'Channels';
channels.tag                = 'channels';
channels.strtype            = 's';
channels.num                = [1 Inf];
channels.val                = {'pupil'};
channels.help               = {['Enter a list of channels ', ...
    '(numbers or names)', ...
    'to work on. ', ...
    'Default is pupil channels. Channel names which depend on eyes will ', ...
    'automatically be expanded. E.g. pupil becomes pupil_l.']};


%% Enable missing
enable_missing        = cfg_const;
enable_missing.name   = 'Enabled';
enable_missing.tag    = 'enable_missing';
enable_missing.val    = {1};
enable_missing.help    = {'Missing is enabled.'};

%% Disable missing
disable_missing        = cfg_const;
disable_missing.name   = 'Disabled';
disable_missing.tag    = 'disable_missing';
disable_missing.val    = {0};
disable_missing.help    = {'Missing is disabled.'};

%% Missing
missing                 = cfg_choice;
missing.name            = 'Missing';
missing.tag             = 'missing';
missing.values          = {enable_missing, disable_missing};
missing.val             = {enable_missing};
missing.help            = {['If enabled an additional channel containing ', ...
    'additional information about valid data points will be written. ', ...
    'Data points equal to 1 describe epochs which have been discriminated ', ...
    'as invalid during validation (=missing). Data points equal ', ...
    'to 0 describe epochs of valid data. This function may be ', ...
    'enabled in combination with enabled interpolation.']};

%% Overwrite original
overwrite_original      = cfg_const;
overwrite_original.name = 'Overwrite original file';
overwrite_original.tag  = 'overwrite_original';
overwrite_original.val  = {1};
overwrite_original.help = {'Overwrite original data file.'};

%% File path
file_path               = cfg_files;
file_path.name          = 'File path';
file_path.tag           = 'file_path';
file_path.filter        = 'dir';
file_path.help          = {'Path to new file.'};

%% File name
file_name               = cfg_entry;
file_name.name          = 'File name';
file_name.tag           = 'file_name';
file_name.strtype       = 's';
file_name.num           = [1 Inf];
file_name.help          = {'Name of new file.'};


%% Create new file
new_file                = cfg_branch;
new_file.name           = 'Create new file';
new_file.tag            = 'new_file';
new_file.val            = {file_path, file_name};
new_file.help           = {['Write data into given file. The original ', ...
    'data will be copied to the given file and the new data channels ', ...
    'will, according to the channel output, either be added or replace ', ...
    'the original channels.']};

%% File output
file_output             = cfg_choice;
file_output.name        = 'File output';
file_output.tag         = 'file_output';
file_output.values      = {overwrite_original, new_file};
file_output.val         = {overwrite_original};
file_output.help        = {['Write data to a new file or overwrite ',...
    'original data file.']};

% define channel_action
% ------------------------------------------------------
channel_action = cfg_menu;
channel_action.name = 'Channel action';
channel_action.tag  = 'channel_action';
channel_action.values = {'add', 'replace'};
channel_action.labels = {'Add', 'Replace'};
channel_action.val = {'add'};
channel_action.help = {'Choose whether to add the new channels or replace a channel previously added by this method.'};

%% plot_gaze_coords
plot_gaze_coords           = cfg_menu;
plot_gaze_coords.name      = 'Plot gaze coords and fixation point(s)';
plot_gaze_coords.tag       = 'plot_gaze_coords';
plot_gaze_coords.val       = {false};
plot_gaze_coords.labels    = {'No', 'Yes'};
plot_gaze_coords.values    = {false, true};
plot_gaze_coords.help      = {['Define whether to plot the gaze coordinates ',...
                               'for visual inspection of the validation ',...
                               'process. Default is false.']};

%% Output settings
output                  = cfg_branch;
output.name             = 'Output settings';
output.tag              = 'output_settings';
output.val              = {file_output, channel_action, plot_gaze_coords};

%% Executable branch
find_valid_fixations      = cfg_exbranch;
find_valid_fixations.name = 'Find valid fixations';
find_valid_fixations.tag  = 'find_valid_fixations';
find_valid_fixations.val  = {datafile, eyes, val_method, channels, missing, output};
find_valid_fixations.prog = @pspm_cfg_run_find_valid_fixations;
find_valid_fixations.vout = @pspm_cfg_vout_find_valid_fixations;
find_valid_fixations.help = {['Pupil data time series can contain missing ', ...
    'values due to blinks and head movements. Additionally, pupil ', ...
    'measurements obtained from a video-based eye tracker depend on the ', ...
    'gaze angle, therefore breaks of fixation can be excluded. Valid ', ...
    'fixations can be determined by setting an a priori threshold with ', ...
    'respect to the fixation point (in degree visual ', ...
    'angle) for x- or y-gaze-positions.'], ...
    ['The input are x- and y-gaze positions converted to length units ', ...
    '(see pspm_convert_pixel2unit()). The output is a time series with NaN ', ...
    'values during invalid fixations ', ...
    '(discriminated according to parameters passed to the function).'], ...
    'References:', ...
    'Korn, Bach (2016) Journal of Vision', ...
    'Hayes & Petrov, 2015, Behavior Research Methods'};

function vout = pspm_cfg_vout_find_valid_fixations(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% only cfg_files
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
