classdef pspm_tam_test < matlab.unittest.TestCase

methods (Test)

function testSingleConditionTrialAverage(testCase)

    %% Parameters
    sr = 10;
    duration = 50;
    window = 5;

    %% Known trial response
    t = (0:1/sr:window-1/sr)';

    response = exp( ...
        -((t - 2).^2) / (2 * 0.5^2));

    %% Continuous pupil signal
    y = zeros(duration * sr, 1);

    onsets = [10 20 30];

    for iTrial = 1:numel(onsets)

        startSample = round(onsets(iTrial) * sr) + 1;
        stopSample = startSample + numel(response) - 1;

        y(startSample:stopSample) = ...
            y(startSample:stopSample) + response;

    end

    %% Timing
    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    %% Create PsPM pupil file
    data = cell(1,1);

    data{1}.header = struct( ...
        'chantype', 'pupil', ...
        'sr', sr, ...
        'units', 'a.u.');

    data{1}.data = y(:);

    infos.duration = duration;
    infos.durationinfo = 'Duration in seconds';
    infos.source = struct();

    datafile = [tempname '.mat'];
    save(datafile, 'data', 'infos');
    



    testCase.addTeardown(@() deleteIfExists(datafile));

    %% Verify test file itself
    [sts, loaded] = pspm_load_channel( datafile, 'pupil', 'pupil');

    testCase.verifyEqual(sts, 1);
    testCase.verifyEqual(loaded.header.sr, sr);
    testCase.verifyEqual(loaded.data(:), y(:));


    %% Configure TAM model
    modelfile = [tempname '.mat'];
    testCase.addTeardown(@() deleteIfExists(modelfile));

    model = struct();

    model.modelfile = modelfile;
    model.datafile = {datafile};
    model.timing = {timing};

    model.timeunits = 'seconds';
    model.window = window;

    model.modelspec = 'dilation';
    model.modality = 'pupil';
    model.channel = 'pupil';

    % Keep preprocessing simple for this test
    model.norm = 0;
    model.baseline = 0;
    model.norm_max = 0;
    % model.std_exp_cond = 'none';

    options = struct();
    options.overwrite = 1;

    %% Run TAM
    [sts, tam] = pspm_tam(model, options);

    %% Basic output checks
    testCase.verifyTrue(isstruct(tam));
    testCase.verifyTrue(isfield(tam, 'data'));
    testCase.verifyTrue(isfield(tam.data, 'Y'));
    testCase.verifyEqual(numel(tam.data.Y), 1);
end

end

end


function deleteIfExists(filename)

if exist(filename, 'file')
delete(filename);
end

end