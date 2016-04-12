function [find_valid_fixations] = scr_cfg_find_valid_fixations(job)
% function [find_valid_fixations] = scr_cfg_find_valid_fixations(job)
%
% Matlabbatch function for scr_find_valid_fixations
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

%% Data file
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 Inf];
datafile.help    = {['Specify the PsPM datafile containing the imported ', ...
    'pupil data.']};

%% Disable fixation validation
disable_fixation_validation       = cfg_const;
disable_fixation_validation.name  = 'Disabled';
disable_fixation_validation.tag   = 'disable_fixation_validation';
disable_fixation_validation.val   = {0};
disable_fixation_validation.help  = {['Validation of fixation is disabled. Only blinks ', ...
    'will cause invalid data points.']};

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
distance.strtype              = 'i';
distance.num                  = [1 1];
distance.help                 = {'Distance between eyes and screen.'};

%% Actual aspect
aspect_actual                      = cfg_entry;
aspect_actual.name                 = 'Actual hardware aspect ratio';
aspect_actual.tag                  = 'aspect_actual';
aspect_actual.strtype              = 'i';
aspect_actual.num                  = [1 2];
aspect_actual.help                 = {'Aspect ratio of the hardware (e.g. [16 9]).'};

%% Used aspect
aspect_used                      = cfg_entry;
aspect_used.name                 = 'Used aspect ratio';
aspect_used.tag                  = 'aspect_used';
aspect_used.strtype              = 'i';
aspect_used.num                  = [1 2];
aspect_used.help                 = {'Usually, this is the same as the ', ...
    'actual aspect ratio. But in some cases, the used aspect ratio ', ...
    'may differ (e.g., because the software does not support [16 9] ', ...
    'and therefore [5 4] is set).'};

%% Screen size
screen_size                      = cfg_entry;
screen_size.name                 = 'Screen size';
screen_size.tag                  = 'screen_size';
screen_size.strtype              = 'r';
screen_size.num                  = [1 1];
screen_size.help                 = {'Size of the screen in inches (diagonal).'};

%% Screen settings
screen_settings                  = cfg_branch;
screen_settings.name             = 'Screen settings';
screen_settings.tag              = 'screen_settings';
screen_settings.val              = {aspect_actual, aspect_used, screen_size};
screen_settings.help             = {'Attributes of the used screen.'};

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
fixpoint_file.help    = {['.mat File containing a variable F with an ', ...
    'nx2 matrix. N should have the length of the recorded data and each ', ...
    'row should define the fixation point for one recorded data row.']};

%% Point
fixpoint                = cfg_entry;
fixpoint.name           = 'Point';
fixpoint.tag            = 'fixpoint';
fixpoint.strtype        = 'r';
fixpoint.num            = [1 2];
fixpoint.help           = {['If the fixation point does not change ', ...
    'during the acquisition, specify x- and y-coordinates of the constant fixation point.']};

%% Fixation point
fixation_point                      = cfg_choice;
fixation_point.name                 = 'Fixation point';
fixation_point.tag                  = 'fixation_point';
fixation_point.val                  = {fixpoint_default};
fixation_point.values               = {fixpoint_default, fixpoint_file, fixpoint};
fixation_point.help                 = {['Point of fixation. Should be ', ...
    'given in pixels, according to the x- and y-coordinates set by the eye tracker software.']};

%% Enable fixation validation
enable_fixation_validation       = cfg_branch;
enable_fixation_validation.name  = 'Enabled';
enable_fixation_validation.tag   = 'enable_fixation_validation';
enable_fixation_validation.val   = {box_degree, distance, screen_settings, fixation_point};
enable_fixation_validation.help  = {['Validation of fixation is enabled. ', ...
    'Blinks and invalid fixations will cause invalid data points. ']};

%% Validate fixations
validate_fixations        = cfg_choice;
validate_fixations.name   = 'Validate fixations';
validate_fixations.tag    = 'validate_fixations';
validate_fixations.val    = {disable_fixation_validation};
validate_fixations.values = {disable_fixation_validation, enable_fixation_validation};
validate_fixations.help   = {['Disable or enable validation of fixations ', ...
    'within a given range on the screen (in degree visual angle).']};

%% Enable interpolation
enable_interpolation        = cfg_const;
enable_interpolation.name   = 'Enabled';
enable_interpolation.tag    = 'enable_interpolation';
enable_interpolation.val    = {1};
enable_interpolation.help    = {'Interpolation is enabled.'};

%% Disable interpolation
disable_interpolation        = cfg_const;
disable_interpolation.name   = 'Disabled';
disable_interpolation.tag    = 'disable_interpolation';
disable_interpolation.val    = {0};
disable_interpolation.help    = {'Interpolation is disabled.'};

%% Interpolate
interpolate                 = cfg_choice;
interpolate.name            = 'Interpolate';
interpolate.tag             = 'interpolate';
interpolate.values          = {enable_interpolation, disable_interpolation};
interpolate.val             = {enable_interpolation};
interpolate.help            = {['If interpolation is enabled NaN values ', ...
    'during blinks and invalid fixations in pupil channels will be ', ...
    'linearly interpolated. Otherwise NaN values remain ', ...
    '(and the GLM function will treat these data points as missing). ']};

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
missing.help            = {['If interpolation is enabled NaN values ', ...
    'during blinks and invalid fixations in pupil channels will be ', ...
    'linearly missingd. Otherwise NaN values remain and interpolation ', ...
    'as well as defining as missing is left over to the GLM function.']};

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

%% Add channel
add_channel             = cfg_const;
add_channel.name        = 'Add channel';
add_channel.tag         = 'add_channel';
add_channel.val         = {1};
add_channel.help        = {['New data channels will be added at the end of the file.']};

%% Replace channel
replace_channel             = cfg_const;
replace_channel.name        = 'Replace channel';
replace_channel.tag         = 'replace_channel';
replace_channel.val         = {1};
replace_channel.help        = {['The function tries to replace the ', ...
    'existing data channels. If there is no existing data channel found, ', ...
    'the new channel will be added at the end of the file (very likely ', ...
    'applies to the new missing data channels).']};

%% Channel output
channel_output          = cfg_choice;
channel_output.name     = 'Channel output';
channel_output.tag      = 'channel_output';
channel_output.values   = {add_channel, replace_channel};
channel_output.val      = {add_channel};
channel_output.help     = {['Define whether the data channels should be ', ...
    'added or replace the original data channels.']};

%% Output settings
output                  = cfg_branch;
output.name             = 'Output settings';
output.tag              = 'output_settings';
output.val              = {file_output, channel_output};

%% Executable branch
find_valid_fixations      = cfg_exbranch;
find_valid_fixations.name = 'Find valid fixations';
find_valid_fixations.tag  = 'find_valid_fixations';
find_valid_fixations.val  = {datafile, validate_fixations, interpolate, missing, output};
find_valid_fixations.prog = @scr_cfg_run_find_valid_fixations;
find_valid_fixations.vout = @scr_cfg_vout_find_valid_fixations;
find_valid_fixations.help = {['Pupil data time series can contain missing ', ...
    'values due to blinks and head movements. Additionally, pupil ', ...
    'measurements obtained from a video-based eye tracker depend on the ', ...
    'gaze angle, therefore breaks of fixation can be excluded. Valid ', ...
    'fixations can be determined by setting an a priori threshold with ', ...
    'respect to the fixation point (in degree visual angle) for x- or y-gaze-positions.'], ...
    'References:', ...
    'Korn, Bach (2016) Journal of Vision'};

function vout = scr_cfg_vout_find_valid_fixations(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% only cfg_files
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});