classdef pspm_tam_test < matlab.unittest.TestCase


properties (TestParameter)
    nFiles = struct( ...
        'oneFile', 1, ...
        'twoFiles', 2);
end

methods (Test)

function testSingleConditionTrialAverage(testCase, nFiles)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    response = exp(-((t - 2).^2) / (2 * 0.5^2));

    y = zeros(duration * sr, 1);
    onsets = [10 20 30];

    for iTrial = 1:numel(onsets)
        startSample = round(onsets(iTrial) * sr) + 1;
        stopSample = startSample + numel(response) - 1;

        y(startSample:stopSample) = ...
            y(startSample:stopSample) + response;
    end

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    datafiles = cell(1, nFiles);

    for k = 1:nFiles

        data = cell(1,1);
        data{1}.header = struct( ...
            'chantype', 'pupil', ...
            'sr', sr, ...
            'units', 'a.u.');

        data{1}.data = y(:);

        infos.duration = duration;
        infos.durationinfo = 'Duration in seconds';
        infos.source = struct();

        datafiles{k} = [tempname '.mat'];

        save(datafiles{k}, 'data', 'infos');

        testCase.addTeardown( ...
            @() deleteIfExists(datafiles{k}));
    end

    modelfile = [tempname '.mat'];
    testCase.addTeardown(@() deleteIfExists(modelfile));

    model = struct();
    model.modelfile = modelfile;

    model.datafile = datafiles;

    % Same timing definition for each file/session
    model.timing = repmat({timing}, 1, nFiles);

    model.timeunits = 'seconds';
    model.window = window;
    model.modelspec = 'dilation';
    model.modality = 'pupil';
    model.channel = 'pupil';
    model.norm = 0;
    model.baseline = 0;
    model.norm_max = 0;

    options.overwrite = 1;

    [sts, tam] = pspm_tam(model, options);

    testCase.verifyEqual(sts, 1);

    expected = response - response(1);

    testCase.verifyEqual( ...
        tam.data.Y{1}, ...
        expected(:), ...
        'AbsTol', 1e-10);

    % Sampling rate should stay 10 Hz for every session
    testCase.verifyEqual( ...
        tam.data.sr, ...
        repmat({sr}, 1, nFiles));

end

function testDownsamplingTo5Hz(testCase)
    sr = 10;
    duration = 50;
    window = 5;

    % 5 seconds at 10 Hz -> 50 samples
    t = (0:1/sr:window-1/sr)';
    response = exp(-((t - 2).^2) / (2 * 0.5^2));

    y = zeros(duration * sr, 1);
    onsets = [10 20 30];

    for iTrial = 1:numel(onsets)
        startSample = round(onsets(iTrial) * sr) + 1;
        stopSample = startSample + numel(response) - 1;

        y(startSample:stopSample) = y(startSample:stopSample) + response;
    end

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    data = cell(1,1);
    data{1}.header = struct( 'chantype', 'pupil', 'sr', sr, 'units', 'a.u.');
    data{1}.data = y(:);

    infos.duration = duration;
    infos.durationinfo = 'Duration in seconds';
    infos.source = struct();

    datafile = [tempname '.mat'];
    save(datafile, 'data', 'infos');
    testCase.addTeardown(@() deleteIfExists(datafile));

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
    model.norm = 0;
    model.baseline = 0;
    model.norm_max = 0;

    % Explicitly request downsampling from 10 Hz to 5 Hz no filtering
    model.filter = struct( 'lpfreq', 'none', 'lporder', 0, 'hpfreq', 'none', 'hporder', 0, 'down', 5, 'direction', 'bi');

    options = struct();
    options.overwrite = 1;

    [sts, tam] = pspm_tam(model, options);

    testCase.assertEqual(sts, 1);

    % 5 seconds at 5 Hz -> 25 samples
    expectedSize = [25 1];

    testCase.verifySize(tam.data.Y{1},   expectedSize); % mean
    testCase.verifySize(tam.data.std{1}, expectedSize);
    testCase.verifySize(tam.data.sem{1}, expectedSize);
    testCase.verifySize(tam.data.X{1},   expectedSize); % t

    testCase.verifyEqual(tam.data.sr{1}, 5);

end

function testLowpassFilterWithoutDownsampling(testCase)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';

    % Signal with a slower response plus high-frequency component
    response = exp(-((t - 2).^2) / (2 * 0.5^2)) ...
        + 0.1 * sin(2*pi*4*t);

    y = zeros(duration * sr, 1);
    onsets = [10 20 30];

    for iTrial = 1:numel(onsets)
        startSample = round(onsets(iTrial) * sr) + 1;
        stopSample = startSample + numel(response) - 1;

        y(startSample:stopSample) = ...
            y(startSample:stopSample) + response;
    end

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

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
    model.norm = 0;
    model.baseline = 0;
    model.norm_max = 0;

    model.filter = struct( ...
        'lpfreq', 1, ...
        'lporder', 1, ...
        'hpfreq', 'none', ...
        'hporder', 0, ...
        'down', 'none', ...
        'direction', 'bi');

    options.overwrite = 1;

    [sts, tam] = pspm_tam(model, options);

    testCase.assertEqual(sts, 1);

    % No downsampling -> still 50 samples
    testCase.verifySize(tam.data.Y{1},   [50 1]);
    testCase.verifySize(tam.data.std{1}, [50 1]);
    testCase.verifySize(tam.data.sem{1}, [50 1]);
    testCase.verifySize(tam.data.X{1},   [50 1]);

    % Sampling rate must stay unchanged
    testCase.verifyEqual(tam.data.sr{1}, 10);

    % Filter flag
    testCase.verifyTrue(tam.data.filtered);

    % Time vector must NOT have been filtered
    expected_t = (1:50)' / sr;

    testCase.verifyEqual( tam.data.X{1}, expected_t, 'AbsTol', 1e-12);

    % Filtering should actually change the signal
    unfiltered = response - response(1);

    testCase.verifyGreaterThan( norm(tam.data.Y{1} - unfiltered), 1e-6);

end


function testTwoSessions(this)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';

    response1 = exp(-((t - 2).^2) / (2 * 0.5^2));
    response2 = 2 * response1;

    onsets = [10 20 30];

    % ----- Session 1 -----
    y1 = zeros(duration * sr, 1);

    for iTrial = 1:numel(onsets)
        startSample = round(onsets(iTrial) * sr) + 1;
        stopSample = startSample + numel(response1) - 1;

        y1(startSample:stopSample) = ...
            y1(startSample:stopSample) + response1;
    end

    % ----- Session 2 -----
    y2 = zeros(duration * sr, 1);

    for iTrial = 1:numel(onsets)
        startSample = round(onsets(iTrial) * sr) + 1;
        stopSample = startSample + numel(response2) - 1;

        y2(startSample:stopSample) = ...
            y2(startSample:stopSample) + response2;
    end

    % Timing for both sessions
    timing1.names = {'condition_1'};
    timing1.onsets = {onsets};
    timing1.durations = {zeros(size(onsets))};

    timing2 = timing1;

    % Temporary files
    datafile1 = [tempname '.mat'];
    datafile2 = [tempname '.mat'];
    modelfile = [tempname '.mat'];

    this.addTeardown(@() deleteIfExists(datafile1));
    this.addTeardown(@() deleteIfExists(datafile2));
    this.addTeardown(@() deleteIfExists(modelfile));

    % Save session 1
    data = cell(1,1);
    data{1}.header = struct( ...
        'chantype', 'pupil', ...
        'sr', sr, ...
        'units', 'a.u.');
    data{1}.data = y1;

    infos.duration = duration;
    infos.durationinfo = 'Duration in seconds';
    infos.source = struct();

    save(datafile1, 'data', 'infos');

    % Save session 2
    data{1}.data = y2;
    save(datafile2, 'data', 'infos');

    % Model
    model = struct();
    model.modelfile = modelfile;

    model.datafile{1} = datafile1;
    model.datafile{2} = datafile2;

    model.timing{1} = timing1;
    model.timing{2} = timing2;

    model.timeunits = 'seconds';
    model.window = window;
    model.modelspec = 'dilation';
    model.modality = 'pupil';
    model.channel = 'pupil';

    model.norm = 0;
    model.baseline = 0;
    model.norm_max = 0;

    model.filter = struct( ...
        'lpfreq', 'none', ...
        'lporder', 1, ...
        'hpfreq', 'none', ...
        'hporder', 1, ...
        'down', 'none', ...
        'direction', 'bi');

    options.overwrite = 1;

    % Run TAM
    [sts, tam] = pspm_tam(model, options);

    this.verifyEqual(sts, 1);

    % Session average:
    % (response1 + response2) / 2 = 1.5 * response1
    expected = (response1 + response2) / 2;

    % TAM baseline correction at first datapoint
    expected = expected - expected(1);

    this.verifyEqual( tam.data.Y{1}, expected(:), 'AbsTol', 1e-10);

    % Both sessions keep 10 Hz
    this.verifyEqual(tam.data.sr, {10, 10});

    % Still one experimental condition
    this.verifyEqual(numel(tam.data.Y), 1);

end


end
end


function deleteIfExists(filename)

if exist(filename, 'file')
delete(filename);
end

end