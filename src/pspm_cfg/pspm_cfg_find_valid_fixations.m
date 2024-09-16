function [FindValidFixa] = pspm_cfg_find_valid_fixations(~)
% ● Description
%   Matlabbatch function for pspm_find_valid_fixations
% ● History
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
box_degree.help         = pspm_cfg_help_format('pspm_find_valid_fixations', 'circle_degree');

%% Distance
distance                = cfg_entry;
distance.name           = 'Distance';
distance.tag            = 'distance';
distance.strtype        = 'r';
distance.num            = [1 1];
distance.help           = pspm_cfg_help_format('pspm_find_valid_fixations', 'distance');

%% unit
unit                    = cfg_menu;
unit.name               = 'Unit';
unit.tag                = 'unit';
unit.values             = {'mm', 'cm', 'm', 'inches'};
unit.labels             = {'mm', 'cm', 'm', 'inches'};
unit.val                = {'mm'};
unit.help               = pspm_cfg_help_format('pspm_find_valid_fixations', 'unit');
%% Resolution
Resol                   = cfg_entry;
Resol.name              = 'Resolution';
Resol.tag               = 'resolution';
Resol.strtype           = 'i';
Resol.num               = [1 2];
Resol.val               = {[1280 1024]};
Resol.help              = pspm_cfg_help_format('pspm_find_valid_fixations', 'options.resolution');
%% Fixation point default
FixPtDefault            = cfg_const;
FixPtDefault.name       = 'Default';
FixPtDefault.tag        = 'default';
FixPtDefault.val        = {1};
FixPtDefault.help       = {['Middle of the screen.']};

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
FixPtVal.help           = {['x/y coordinates of constant fixation point.']};

%% Fixation point
FixPt                   = cfg_choice;
FixPt.name              = 'Fixation point';
FixPt.tag               = 'fixation_point';
FixPt.val               = {FixPtDefault};
FixPt.values            = {FixPtDefault, FixPtFile, FixPtVal};
FixPt.help              = pspm_cfg_help_format('pspm_find_valid_fixations', 'options.fixation_point');
%% Validation settings
ValidSet                = cfg_branch;
ValidSet.name           = 'Fixation point';
ValidSet.tag            = 'validation_settings';
ValidSet.val            = {box_degree, distance, unit, Resol, FixPt};
ValidSet.help           = {};

%% Validate on bitmap
bitmap                  = cfg_files;
bitmap.name             = 'Bitmap file';
bitmap.tag              = 'bitmap_file';
bitmap.num              = [1 1];
bitmap.help             = pspm_cfg_help_format('pspm_find_valid_fixations', 'bitmap');
%% Validation method
val_method              = cfg_choice;
val_method.name         = 'Validation method';
val_method.tag          = 'val_method';
val_method.values       = {ValidSet,bitmap};
val_method.help         = {};
%% Missing
missing                 = cfg_menu;
missing.name            = 'Add channel with information invalid data points';
missing.tag             = 'missing';
missing.labels          = {'Yes', 'No'};
missing.values          = {1, 0};
missing.val             = {0};
missing.help            = pspm_cfg_help_format('pspm_find_valid_fixations', 'options.add_invalid');
%% plot_gaze_coords
plot_gaze_coords        = cfg_menu;
plot_gaze_coords.name   = 'Plot gaze coords and fixation point(s)';
plot_gaze_coords.tag    = 'plot_gaze_coords';
plot_gaze_coords.val    = {false};
plot_gaze_coords.labels = {'No', 'Yes'};
plot_gaze_coords.values = {false, true};
plot_gaze_coords.help   = pspm_cfg_help_format('pspm_find_valid_fixations', 'options.plot_gaze_coords');
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
