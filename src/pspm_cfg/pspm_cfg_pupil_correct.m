function [pupil_correct] = pspm_cfg_pupil_correct(job)
    % Matlabbatch function for pspm_pupil_correct_eyelink
    %__________________________________________________________________________
    % (C) 2019 Eshref Yozdemir (University of Zurich)

    % Initialise
    global settings
    if isempty(settings), pspm_init; end

    %% Data file
    datafile         = cfg_files;
    datafile.name    = 'Data File';
    datafile.tag     = 'datafile';
    datafile.num     = [1 1];
    datafile.help    = {'Specify the PsPM datafile containing the pupil and gaze recordings ', settings.datafilehelp};

    screen_size_px      = cfg_entry;
    screen_size_px.name = 'Screen resolution';
    screen_size_px.tag  = 'screen_size_px';
    screen_size_px.num  = [1 2];
    screen_size_px.help = {'Specify screen resolution ([width height]) in pixels'};

    screen_size_mm      = cfg_entry;
    screen_size_mm.name = 'Screen size';
    screen_size_mm.tag  = 'screen_size_mm';
    screen_size_mm.num  = [1 2];
    screen_size_mm.help = {'Specify screen size ([width height]) in milimeters'};

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

    chan_nr = cfg_entry;
    chan_nr.name = 'Channel number';
    chan_nr.tag  = 'chan_nr';
    chan_nr.num  = [1 1];
    chan_nr.help = {'Enter a channel number'};

    chan_def = cfg_menu;
    chan_def.name = 'Channel definition';
    chan_def.tag = 'chan_def';
    chan_def.values = {'pupil', 'pupil_l', 'pupil_r', 'pupil_l_pp', 'pupil_r_pp'};
    chan_def.labels = {'Best pupil', 'Left pupil', 'Right pupil', 'Left preprocessed pupil', 'Right preprocessed pupil'};
    chan_def.val = {'pupil'};
    chan_def.help = {['Choose the channel definition. Only the last channel in the file corresponding to the selection ',...
        'will be corrected.']};

    channel  = cfg_choice;
    channel.name = 'Channel to correct';
    channel.tag = 'channel';
    channel.values = {chan_def, chan_nr};
    channel.val = {chan_def};
    channel.help = {'Choose the channel to correct.'};

    channel_action = cfg_menu;
    channel_action.name = 'Channel action';
    channel_action.tag  = 'channel_action';
    channel_action.values = {'add', 'replace'};
    channel_action.labels = {'Add', 'Replace'};
    channel_action.val = {'replace'};
    channel_action.help = {'Choose whether to add the corrected channel or replace a previously corrected channel.'};

    %% Executable branch
    pupil_correct      = cfg_exbranch;
    pupil_correct.name = 'Pupil foreshortening error correction';
    pupil_correct.tag  = 'pupil_correct';
    pupil_correct.val  = {datafile, screen_size_px, screen_size_mm, mode, channel, channel_action};
    pupil_correct.prog = @pspm_cfg_run_pupil_correct;
    pupil_correct.vout = @pspm_cfg_vout_pupil_correct;
    pupil_correct.help = {['Perform pupil foreshortening error correction using the equations described in ',...
        'the reference paper.'],...
        ['To perform correction, we define the coordinate system centered on the pupil. In this system, x coordinates ',...
         'grow towards right for a person looking forward in an axis perpendicular to the screen. y coordinates grow',...
         'upwards and z coordinates grow ',...
         'towards the screen.'],...
        ['Reference: ', ...
        'Hayes, Taylor R., and Alexander A. Petrov. "Mapping and correcting the',...
        'influence of gaze position on pupil size measurements." Behavior',...
        'Research Methods 48.2 (2016): 510-527.']};
end

function vout = pspm_cfg_vout_pupil_correct(job)
    vout = cfg_dep;
    vout.sname      = 'Output File';
    % only cfg_files
    vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
    vout.src_output = substruct('()',{':'});
end
