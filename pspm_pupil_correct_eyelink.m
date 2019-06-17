function [sts, pupil_corrected] = pspm_pupil_correct_eyelink(pupil_mm, gaze_x_px, gaze_y_px, options)
    % pspm_pupil_correct performs pupil foreshortening error (PFE) correction specifically
    % for the outputs of pspm_get_eyelink following the steps described in [1].
    %  
    %   FORMAT:
    %       [sts, pupil_corrected] = pspm_pupil_correct_eyelink(pupil_mm, gaze_x_px, gaze_y_px, options)
    %
    %   INPUT:
    %       pupil_mm:                Numeric array containing pupil diameter.
    %                                (Unit: mm)
    %
    %       gaze_x_px:               Numeric array containing gaze x positions.
    %                                (Unit: pixel)
    %
    %       gaze_y_px:               Numeric array containing gaze y positions.
    %                                (Unit: pixel)
    %
    %       options:
    %           Mandatory:
    %               screen_size_px:  Screen size (width x height).
    %                                (Unit: pixel)
    %
    %               screen_size_mm:  Screen size (width x height).
    %                                (Unit: mm)
    %
    %               mode:            Conversion mode. Must be one of 'auto' or 'manual'.
    %                                If 'auto', then optimized conversion parameters
    %                                in Table 3 of [1] will be used. In 'auto' mode,
    %                                options struct must contain C_z parameter described
    %                                below. Further, C_z must be one of 495, 525 or 625.
    %                                The other parameters will be set according to which
    %                                of these three C_z is equal to.
    %
    %                                If 'manual', then all of C_x, C_y, C_z, S_x, S_y, S_z
    %                                fields must be provided.
    %
    %               C_z:             See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
    %
    %           Optional:
    %               C_x:             See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
    %
    %               C_y:             See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
    %
    %               S_x:             See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
    %
    %               S_y:             See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
    %
    %               S_z:             See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
    %
    %   OUTPUT:
    %       pupil_corrected:         Corrected pupil data.
    %
    % [1] Hayes, Taylor R., and Alexander A. Petrov. "Mapping and correcting the
    %     influence of gaze position on pupil size measurements." Behavior
    %     Research Methods 48.2 (2016): 510-527.
    %__________________________________________________________________________
    % (C) 2019 Eshref Yozdemir (University of Zurich)

    % initialise
    % -------------------------------------------------------------------------
    global settings;
    if isempty(settings), pspm_init; end
    sts = -1;

    % input checks
    % -------------------------------------------------------------------------
    if ~isfield(options, 'screen_size_px')
        warning('ID:invalid_input', 'options struct must contain ''screen_size_px''');
        return;
    end
    if ~isfield(options, 'screen_size_mm')
        warning('ID:invalid_input', 'options struct must contain ''screen_size_mm''');
        return;
    end
    if ~isnumeric(options.screen_size_px)
        warning('ID:invalid_input', 'options.screen_size_px must be numeric');
        return;
    end
    if ~isnumeric(options.screen_size_mm)
        warning('ID:invalid_input', 'options.screen_size_mm must be numeric');
        return;
    end
    if ~isfield(options, 'mode')
        warning('ID:invalid_input', 'options struct must contain ''mode''');
        return;
    end
    if ~isfield(options, 'C_z')
        warning('ID:invalid_input', 'options struct must contain ''C_z''');
        return;
    end
    if ~any(strcmpi(options.mode, {'auto', 'manual'}))
        warning('ID:invalid_input', 'options.mode must be ''auto'' or ''manual''');
        return;
    end
    if ~isnumeric(options.C_z)
        warning('ID:invalid_input', 'options.C_z must be numeric');
        return;
    end

    % create default arguments
    % --------------------------------------------------------------
    all_fieldnames = {'C_x', 'C_y', 'C_z', 'S_x', 'S_y', 'S_z'};
    default_params = containers.Map('KeyType', 'double', 'ValueType', 'any');
    default_params(495) = [103, -215, 495, -142, 206, 736];
    default_params(525) = [165, -239, 525, -87, 140, 851];
    default_params(625) = [183, -230, 625, -76, 156, 937];
    if strcmpi(options.mode, 'auto')
        if ismember(options.C_z, cell2mat(keys(default_params)))
            for i = 1:numel(all_fieldnames)
                name_i = all_fieldnames{i};
                values = default_params(options.C_z);
                options.(name_i) = values(i);
            end
        else
            warning('ID:invalid_input', 'options.C_z must be one of 495, 525 or 625 in auto mode');
            return;
        end
    end

    % conversion
    % -------------------------------------------------------------------------
    gaze_x_mm = gaze_x_px * (options.screen_size_mm(1) / options.screen_size_px(1));
    gaze_y_mm = gaze_y_px * (options.screen_size_mm(2) / options.screen_size_px(2));

    % correction
    % -------------------------------------------------------------------------
    [sts, pupil_corrected] = pspm_pupil_correct(pupil_mm, gaze_x_mm, gaze_y_mm, options);
end
