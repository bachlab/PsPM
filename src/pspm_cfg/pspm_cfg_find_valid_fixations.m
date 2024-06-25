function [FindValidFixa] = pspm_cfg_find_valid_fixations(~)
% * Description
%   Matlabbatch function for pspm_find_valid_fixations
% * History
%   Introduced in PsPM 3.1
%   Written in 2016 by Tobias Moser (University of Zurich)
%   Updated in 2024 by Teddy

%% Standard items
datafile         = pspm_cfg_selector_datafile;
chan             = pspm_cfg_selector_channel('pupil_both');
ChanAct          = pspm_cfg_selector_channel_action;

%% Visual angle
box_degree              = cfg_entry;
box_degree.name         = 'Visual angle';
box_degree.tag          = 'box_degree';
box_degree.strtype      = 'i';
box_degree.num          = [1 1];
box_degree.help         = {['Range of valid fixations (around a ', ...
                            'fixation point). The value has to be ', ...
                            'in degree visual angle.']};
%% Distance
distance                = cfg_entry;
distance.name           = 'Distance';
distance.tag            = 'distance';
distance.strtype        = 'r';
distance.num            = [1 1];
distance.help           = {['Distance between eyes and screen in ', ...
                            'length units.']};
%% unit
unit                    = cfg_menu;
unit.name               = 'Unit';
unit.tag                = 'unit';
unit.values             = {'mm', 'cm', 'm', 'inches'};
unit.labels             = {'mm', 'cm', 'm', 'inches'};
unit.val                = {'mm'};
unit.help               = {'Unit in which the distance is given'};
%% Resolution
Resol                   = cfg_entry;
Resol.name              = 'Resolution';
Resol.tag               = 'resolution';
Resol.strtype           = 'i';
Resol.num               = [1 2];
Resol.val               = {[1280 1024]};
Resol.help              = {['Resolution to which the fixation ', ...
                            'point refers (maximum value of the x- ', ...
                            'and y-coordinates). This can ', ...
                            'be the resolution set in cogent / ', ...
                            'psychtoolbox (e.g. [1280 1024]) ', ...
                            'or the width and height of the screen ', ...
                            'in length values (e.g. [50 40]).']};
%% Fixation point default
FixPtDefault            = cfg_const;
FixPtDefault.name       = 'Default';
FixPtDefault.tag        = 'default';
FixPtDefault.val        = {1};
FixPtDefault.help       = {['If default is set, the middle of the ', ...
                            'screen will be defined as fixation point.']};

%% Fixation point file
FixPtFile               = cfg_files;
FixPtFile.name          = 'File';
FixPtFile.tag           = 'fixpoint_file';
FixPtFile.num           = [1 1];
FixPtFile.help          = {['.mat file containing a variable F with an ', ...
                            'n x 2 matrix. N should have the length of ', ...
                            'the recorded data and each row should ', ...
                            'define the fixation point for the ', ...
                            'respective recorded data row.']};
%% Fixation point value
FixPtVal                = cfg_entry;
FixPtVal.name           = 'Point';
FixPtVal.tag            = 'fixpoint';
FixPtVal.strtype        = 'r';
FixPtVal.num            = [1 2];
FixPtVal.help           = {['If the fixation point does not change ', ...
                            'during the acquisition, specify x- and ', ...
                            'y-coordinates of the constant fixation ', ...
                            'point.']};
%% Fixation point
FixPt                   = cfg_choice;
FixPt.name              = 'Fixation point';
FixPt.tag               = 'fixation_point';
FixPt.val               = {FixPtDefault};
FixPt.values            = {FixPtDefault, FixPtFile, FixPtVal};
FixPt.help              = {['X- and y-coordinates for the point',...
                            'of fixation with respect to the given ',...
                            'resolution.']};
%% Validation settings
ValidSet                = cfg_branch;
ValidSet.name           = 'Fixation point';
ValidSet.tag            = 'validation_settings';
ValidSet.val            = {box_degree, distance, unit, Resol, FixPt};
ValidSet.help           = {['Settings to validate fixations within a ', ...
                            'given range on the screen (in degree ',...
                            'visual angle).']};
%% Validate on bitmap
bitmap                  = cfg_files;
bitmap.name             = 'Bitmap file';
bitmap.tag              = 'bitmap_file';
bitmap.num              = [1 1];
bitmap.help             = {['.mat file containing a variable bitmap ',...
                            'with an n x m matrix. The matrix bitmap ',...
                            'represents the display (n = height and ',...
                            'm = width) and holds for each position. ',...
                            'A 1, where a gaze point is valid, and a ',...
                            '0 otherwise.',...
                            'Gaze data at invalid positions (indicated ',...
                            'by bitmap or outside the display) are ',...
                            'set to NaN.']};
%% Validation method
val_method              = cfg_choice;
val_method.name         = 'Validation method';
val_method.tag          = 'val_method';
val_method.values       = {ValidSet,bitmap};
val_method.help         = {['You can either validate the data by ',...
                            'indicating a range on the screen (in ',...
                            'degree visual angle) and fixation point(s) ',...
                            'or by passing a bitmap representing the ',...
                            'screen and holding a 1 for all the ',...
                            'fixations that are valid.']};
%% Missing
missing                 = cfg_menu;
missing.name            = 'Enable missing validation';
missing.tag             = 'missing';
missing.labels          = {'Yes', 'No'};
missing.values          = {1, 0};
missing.val             = {0};
missing.help            = {['If enabled an additional channel ', ...
                            'containing additional information about ', ...
                            'valid data points will be written. ', ...
                            'Data points equal to 1 describe epochs ', ...
                            'which have been discriminated ', ...
                            'as invalid during validation (=missing). ', ...
                            'Data points equal to 0 describe epochs of ', ...
                            'valid data. This function may be enabled ', ...
                            'in combination with enabled interpolation.']};

%% plot_gaze_coords
plot_gaze_coords        = cfg_menu;
plot_gaze_coords.name   = 'Plot gaze coords and fixation point(s)';
plot_gaze_coords.tag    = 'plot_gaze_coords';
plot_gaze_coords.val    = {false};
plot_gaze_coords.labels = {'No', 'Yes'};
plot_gaze_coords.values = {false, true};
plot_gaze_coords.help   = {['Define whether to plot the gaze coordinates ',...
                            'for visual inspection of the validation ',...
                            'process. Default is false.']};
%% Output settings
output                  = cfg_branch;
output.name             = 'Output settings';
output.tag              = 'output_settings';
output.val              = {missing, plot_gaze_coords};
%% Executable branch
FindValidFixa           = cfg_exbranch;
FindValidFixa.name      = 'Find valid fixations';
FindValidFixa.tag       = 'find_valid_fixations';
FindValidFixa.val       = {datafile, chan, ChanAct, val_method, output};
FindValidFixa.prog      = @pspm_cfg_run_find_valid_fixations;
FindValidFixa.vout      = @pspm_cfg_vout_outchannel;
FindValidFixa.help      = pspm_cfg_help_format('pspm_find_valid_fixations');