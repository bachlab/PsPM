function [pupil_correct] = pspm_cfg_pupil_correct
% Matlabbatch function for pspm_pupil_correct_eyelink
%__________________________________________________________________________
% (C) 2019 Eshref Yozdemir (University of Zurich)

%% Standard items
datafile         = pspm_cfg_selector_datafile;
channel          = pspm_cfg_selector_channel('pupil');
channel_action   = pspm_cfg_selector_channel_action;

%% Specific items
screen_size_px      = cfg_entry;
screen_size_px.name = 'Screen resolution';
screen_size_px.tag  = 'screen_size_px';
screen_size_px.num  = [1 2];
screen_size_px.val = {[NaN NaN]};
screen_size_px.help = {'Specify screen resolution ([width height]) in pixels. Only required if gaze data in the file is in pixels.'};

screen_size_mm      = cfg_entry;
screen_size_mm.name = 'Screen size';
screen_size_mm.tag  = 'screen_size_mm';
screen_size_mm.num  = [1 2];
screen_size_mm.val = {[NaN NaN]};
screen_size_mm.help = {'Specify screen size ([width height]) in milimeters. Only required if gaze data in the file is in pixels.'};

C_x      = cfg_entry;
C_x.name = 'C_x';
C_x.tag  = 'C_x';
C_x.num  = [1 1];
C_x.help = {'Horizontal displacement of the camera with respect to the eye. (Unit: milimeters)'};

C_y      = cfg_entry;
C_y.name = 'C_y';
C_y.tag  = 'C_y';
C_y.num  = [1 1];
C_y.help = {'Vertical displacement of the camera with respect to the eye. (Unit: milimeters)'};

C_z      = cfg_entry;
C_z.name = 'C_z';
C_z.tag  = 'C_z';
C_z.num  = [1 1];
C_z.help = {'Eye to camera Euclidean distance if they are on the same x and y coordinates. (Unit: milimeters)'};

S_x      = cfg_entry;
S_x.name = 'S_x';
S_x.tag  = 'S_x';
S_x.num  = [1 1];
S_x.help = {'Horizontal displacement of the top left corner of the screen with respect to the eye. (Unit: milimeters)'};

S_y      = cfg_entry;
S_y.name = 'S_y';
S_y.tag  = 'S_y';
S_y.num  = [1 1];
S_y.help = {'Vertical displacement of the top left corner of the screen with respect to the eye. (Unit: milimeters)'};

S_z      = cfg_entry;
S_z.name = 'S_z';
S_z.tag  = 'S_z';
S_z.num  = [1 1];
S_z.help = {'Eye to top left screen corner distance if they are on the same x and y coordinates. (Unit: milimeters)'};

C_z_auto = cfg_menu;
C_z_auto.name = C_z.name;
C_z_auto.tag = C_z.tag;
C_z_auto.values = {495, 525, 625};
C_z_auto.labels = {'495', '525', '625'};
C_z_auto.help = C_z.help;
auto_mode = cfg_branch;
auto_mode.name = 'Auto mode';
auto_mode.tag  = 'auto';
auto_mode.val  = {C_z_auto};
auto_mode.help = {['In auto mode, you need to enter C_z value. Other values will be set using ',...
    'the optimized parameters in reference paper which you can find in method help text. Note that you ',...
    'can use auto mode only if your eye-camera-screen geometry setup matches exactly one of the setups ',...
    'given in the reference paper. For information about these setups, please refer to reference article ',...
    'or pupil correction user guide section in PsPM manual. For ease of reference, we include the page from ',...
    'the reference article that describes the three layouts.']};

manual_mode = cfg_branch;
manual_mode.name = 'Manual mode';
manual_mode.tag = 'manual';
manual_mode.val = {C_x, C_y, C_z, S_x, S_y, S_z};
manual_mode.help = {'In manual mode, you need to enter all values defining the eye-camera-screen geometry'};

mode = cfg_choice;
mode.name = 'Correction mode';
mode.tag = 'mode';
mode.values = {auto_mode, manual_mode};
mode.val = {manual_mode};
mode.help = {'Choose the correction mode'};

%% Executable branch
pupil_correct      = cfg_exbranch;
pupil_correct.name = 'Pupil foreshortening error correction';
pupil_correct.tag  = 'pupil_correct';
pupil_correct.val  = {datafile, screen_size_px, screen_size_mm, mode, channel, channel_action};
pupil_correct.prog = @pspm_cfg_run_pupil_correct;
pupil_correct.vout = @pspm_cfg_vout_outchannel;
pupil_correct.help = {['Perform pupil foreshortening error correction using the equations described in ',...
    'the reference paper.'],...
    ['To perform correction, we define the coordinate system centered on the pupil. In this system, x coordinates ',...
     'grow towards right for a person looking forward in an axis perpendicular to the screen. y coordinates grow',...
     'upwards and z coordinates grow ',...
     'towards the screen.'],...
    ['Gaze data in PsPM files can be in pixels or in units such as milimeters. If the gaze values are', ...
    ' already in mm, cm, inches, etc., there is no need to specify any information regarding the screen dimensions.', ...
    ' However, if x or y gaze channel is in pixels, you must specify screen dimension and resolution so that', ...
    ' pixel to mm ratio required to convert the gaze channels to mm can be computed.'], ...
    ['Reference: ', ...
    'Hayes, Taylor R., and Alexander A. Petrov. "Mapping and correcting the',...
    'influence of gaze position on pupil size measurements." Behavior',...
    'Research Methods 48.2 (2016): 510-527.']};
end


