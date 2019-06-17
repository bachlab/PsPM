function [sts, default_settings] = pspm_pupil_pp_options()
    % pspm_pupil_pp_options is a helper function that can be used to modify the
    % behaviour of pspm_pupil_pp function. This function returns the settings
    % structure used by pspm_pupil_pp for pupil preprocessing. You can modify the
    % returned structure and then pass it to pspm_pupil_pp. For explanation of the
    % various options, refer to
    %
    %   - pupil-size/code/helperFunctions/rawDataFilter.m lines 63 to 149,
    %   - pupil-size/code/dataModels/ValidSamplesModel.m lines 357 to 373.
    %
    %   FORMAT:  [sts, default_settings] = pspm_pupil_pp_options
    %       default_settings:            Settings structure.
    %
    %__________________________________________________________________________
    % (C) 2019 Eshref Yozdemir (University of Zurich)

    % initialise
    % -------------------------------------------------------------------------
    global settings;
    if isempty(settings), pspm_init; end
    sts = -1;

    libbase_path = fullfile(fileparts(which('pspm_pupil_pp_options')), 'pupil-size', 'code');
    libpath = {fullfile(libbase_path, 'dataModels'), fullfile(libbase_path, 'helperFunctions')};
    addpath(libpath{:});

    default_settings = PupilDataModel.getDefaultSettings();

    rmpath(libpath{:});
    sts = 1;
end
