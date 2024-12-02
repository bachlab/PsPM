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
screen_size_px.help = pspm_cfg_help_format('pspm_pupil_correct_eyelink', 'options.screen_size_px');

screen_size_mm      = cfg_entry;
screen_size_mm.name = 'Screen size';
screen_size_mm.tag  = 'screen_size_mm';
screen_size_mm.num  = [1 2];
screen_size_mm.val = {[NaN NaN]};
screen_size_mm.help = pspm_cfg_help_format('pspm_pupil_correct_eyelink', 'options.screen_size_mm');

C_x      = cfg_entry;
C_x.name = 'C_x';
C_x.tag  = 'C_x';
C_x.num  = [1 1];
C_x.help = pspm_cfg_help_format('pspm_pupil_correct', 'geometry_setup.C_x');

C_y      = cfg_entry;
C_y.name = 'C_y';
C_y.tag  = 'C_y';
C_y.num  = [1 1];
C_y.help = pspm_cfg_help_format('pspm_pupil_correct', 'geometry_setup.C_y');

C_z      = cfg_entry;
C_z.name = 'C_z';
C_z.tag  = 'C_z';
C_z.num  = [1 1];
C_z.help = pspm_cfg_help_format('pspm_pupil_correct', 'geometry_setup.C_z');

S_x      = cfg_entry;
S_x.name = 'S_x';
S_x.tag  = 'S_x';
S_x.num  = [1 1];
S_x.help = pspm_cfg_help_format('pspm_pupil_correct', 'geometry_setup.S_x');

S_y      = cfg_entry;
S_y.name = 'S_y';
S_y.tag  = 'S_y';
S_y.num  = [1 1];
S_y.help = pspm_cfg_help_format('pspm_pupil_correct', 'geometry_setup.S_y');

S_z      = cfg_entry;
S_z.name = 'S_z';
S_z.tag  = 'S_z';
S_z.num  = [1 1];
S_z.help = pspm_cfg_help_format('pspm_pupil_correct', 'geometry_setup.S_z');

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
auto_mode.help = {};

manual_mode = cfg_branch;
manual_mode.name = 'Manual mode';
manual_mode.tag = 'manual';
manual_mode.val = {C_x, C_y, C_z, S_x, S_y, S_z};
manual_mode.help = {};

mode = cfg_choice;
mode.name = 'Correction mode';
mode.tag = 'mode';
mode.values = {auto_mode, manual_mode};
mode.val = {manual_mode};
mode.help = pspm_cfg_help_format('pspm_pupil_correct_eyelink', 'options.mode');

%% Executable branch
pupil_correct      = cfg_exbranch;
pupil_correct.name = 'Pupil foreshortening error correction';
pupil_correct.tag  = 'pupil_correct';
pupil_correct.val  = {datafile, channel, channel_action, screen_size_px, screen_size_mm, mode};
pupil_correct.prog = @pspm_cfg_run_pupil_correct;
pupil_correct.vout = @pspm_cfg_vout_outchannel;
pupil_correct.help = pspm_cfg_help_format('pspm_pupil_correct_eyelink');
end


