function [sts, out_channel] = pspm_pupil_pp(fn, options)
    % pspm_pupil_pp preprocesses pupil diameter signals given in any unit of
    % measurement. It performs the steps described in [1]. This function
    % uses a modified version of [2]. The modified version with a list of
    % changes from the original is shipped with PsPM under pupil-size directory.
    %  
    % Once the data is preprocessed, according to the option 'channel_action',
    % it will either replace the existing channel or add it as new channel to
    % the provided file.
    %
    %   FORMAT:  [sts, out_channel] = pspm_pupil_pp(fn)
    %            [sts, out_channel] = pspm_pupil_pp(fn, options)
    %
    %       fn:                      [string] Path to the PsPM file which contains 
    %                                the pupil data.
    %       options:
    %           Optional:
    %               channel:         [numeric/string] Channel ID to be preprocessed.
    %                                (Default: 'pupil')
    %                                For the chosen channel type, a preprocessed channel
    %                                will be added whose type has an extra '_pp' suffix.
    %
    %                                .data field of the preprocessed channel contains
    %                                the smoothed, upsampled signal that is the result
    %                                of step 3 in [1].
    %
    %                                .header field of the preprocessed channel contains
    %                                information regarding which samples in the input
    %                                signal were considered valid in addition to the
    %                                usual information of PsPM channels. This valid sample
    %                                info is stored in .header.valid_samples field.
    %
    %               channel_action:  ['add'/'replace'] Defines whether preprocessed
    %                                data should be added ('add') or the corresponding
    %                                preprocessed channel should be replaced ('replace').
    %                                (Default: 'replace')
    %
    %               custom_settings: Settings structure to modify the preprocessing
    %                                steps. Default settings structure can be obtained
    %                                by calling pspm_pupil_pp_options function.
    %                                (Default: Result of pspm_pupil_pp_options)
    %
    %               segments:        Structure with the following fields:
    %                   start:
    %                   end:
    %                   name:
    %
    %               plot_data:       Plot the preprocessing steps if true.
    %                                (Default: false)
    %
    %       out_channel:             Channel ID of the preprocessed output.
    %
    % [1] Kret, Mariska E., and Elio E. Sjak-Shie. "Preprocessing pupil size data:
    %     Guidelines and code." Behavior research methods (2018): 1-7.
    % [2] https://github.com/ElioS-S/pupil-size
    %__________________________________________________________________________
    % (C) 2019 Eshref Yozdemir (University of Zurich)

    % initialise
    % -------------------------------------------------------------------------
    global settings;
    if isempty(settings), pspm_init; end
    sts = -1;

    % create default arguments
    % --------------------------------------------------------------
    if nargin == 1
        options = struct();
    end
    if ~isfield(options, 'channel')
        options.channel = 'pupil';
    end
    if ~isfield(options, 'channel_action')
        options.channel_action = 'replace';
    end

    if ~isfield(options, 'plot_data')
        options.plot_data = false;
    end
    if ~isfield(options, 'custom_settings')
        [lsts, options.custom_settings] = pspm_pupil_pp_options();
        if lsts ~= 1; return; end;
    end

    % input checks
    % -------------------------------------------------------------------------
    if ~ismember(options.channel_action, {'add', 'replace'})
        warning('ID:invalid_input', 'Option channel_action must be either ''add'' or ''replace''');
        return;
    end
    if ~isnumeric(options.channel) && ~ischar(options.channel)
        warning('ID:invalid_input', 'Option channel must be a string or numeric');
        return;
    end
    if ischar(options.channel) && ~strcmpi(options.channel, 'pupil')
        warning('ID:invalid_input', 'Option channel must be an integer or ''pupil''');
        return;
    end

    % load
    % -------------------------------------------------------------------------
    [lsts, infos, data] = pspm_load_data(fn, options.channel);
    if lsts ~= 1; return; end;
    chantype = data{1}.header.chantype;
    unit = data{1}.header.units;
    if ~strcmpi(chantype, 'pupil_l') && ~strcmpi(chantype, 'pupil_r')
        warning('ID:invalid_input', sprintf('Loaded chantype %s does not correspond to a pupil channel', chantype));
        return;
    end

    % preprocess
    % -------------------------------------------------------------------------
    [psts, smooth_signal] = preprocess(data, options.custom_settings, options.plot_data);

    % save
    % -------------------------------------------------------------------------
    [lsts, out_id] = pspm_write_channel(fn, smooth_signal, options.channel_action);
    if lsts ~= 1; return; end;
    out_channel = out_id.channel;

    sts = psts;
end

function [sts, smooth_signal] = preprocess(data, custom_settings, plot_data)
    sts = 0;

    n_samples = numel(data{1}.data);
    sr = data{1}.header.sr;
    diameter.t_ms = linspace(0, 1000 * n_samples / sr, n_samples)';
    diameter.L = data{1}.data;
    if size(diameter.L, 1) == 1
        diameter.L = diameter.L';
    end
    diameter.R = [];
    zeroTime_ms = 0;
    segmentStart = [];
    segmentEnd = [];
    segmentName = {};
    segmentTable = table(segmentStart, segmentEnd, segmentName);

    libbase_path = fullfile(fileparts(which('pspm_pupil_pp')), 'pupil-size', 'code');
    libpath = {fullfile(libbase_path, 'dataModels'), fullfile(libbase_path, 'helperFunctions')};
    addpath(libpath{:});

    new_sr = custom_settings.valid.interp_upsamplingFreq;
    upsampling_factor = new_sr / sr;
    desired_output_samples = int32(upsampling_factor * numel(data{1}.data));

    model = PupilDataModel(data{1}.header.units, diameter, segmentTable, zeroTime_ms, custom_settings);
    model.filterRawData();
    smooth_signal.header.chantype = [data{1}.header.chantype '_pp'];
    smooth_signal.header.units = data{1}.header.units;
    smooth_signal.header.sr = new_sr;

    try
        model.processValidSamples();

        smooth_signal.header.valid_samples.data = model.leftPupil_ValidSamples.samples.pupilDiameter;
        smooth_signal.header.valid_samples.sample_indices = find(model.leftPupil_RawData.isValid);
        smooth_signal.header.valid_samples.valid_percentage = model.leftPupil_ValidSamples.validFraction;

        smooth_signal.data = model.leftPupil_ValidSamples.signal.pupilDiameter;
        n_missing_at_the_end = desired_output_samples - numel(smooth_signal.data);
        smooth_signal.data(end + 1 : end + n_missing_at_the_end) = NaN;

        if plot_data
            model.plotData();
        end
    catch err
        % https://www.mathworks.com/matlabcentral/answers/225796-rethrow-a-whole-error-as-warning
        warning('ID:invalid_data_structure', getReport(err, 'extended', 'hyperlinks', 'on'));
        smooth_signal.data = NaN(desired_output_samples, 1);
        sts = -1;
    end

    rmpath(libpath{:});
    if sts == 0
        sts = 1
    end
end
