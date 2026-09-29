classdef pspm_tam_test < matlab.unittest.TestCase

properties (TestParameter)

    nFiles = struct( ...
        'oneFile', 1, ...
        'twoFiles', 2);

    stdExpCond = struct( ...
        'byName', 'condition_A', ...
        'byIndex', 1);

end


methods (Test)

function testSingleConditionTrialAverage(testCase, nFiles)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    response = exp(-((t - 2).^2) / (2 * 0.5^2));
    onsets = [10 20 30];

    datafiles = testCase.createTestData(nFiles, sr, duration, {response}, {onsets});

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    modelfile = [tempname '.mat'];
    testCase.addTeardown(@() pspm_tam_test.deleteIfExists(modelfile));

    model = struct();
    model.modelfile = modelfile;
    model.datafile = datafiles;
    model.timing = repmat({timing}, 1, nFiles);
    model.timeunits = 'seconds';
    model.window = window;
    model.modelspec = 'dilation';
    model.modality = 'pupil';
    model.channel = 'pupil';
    model.norm = 0;
    model.baseline = 0;
    model.norm_max = 0;
    model.filter = struct('lpfreq', 'none', 'lporder', 1, 'hpfreq', 'none', 'hporder', 1, 'down', 'none', 'direction', 'bi');

    options.overwrite = 1;

    [sts, tam] = pspm_tam(model, options);

    testCase.assertEqual(sts, 1);

    expected = response - response(1);

    testCase.verifyEqual(tam.data.Y{1}, expected(:), 'AbsTol', 1e-10);
    testCase.verifyEqual(tam.data.sr, repmat({sr}, 1, nFiles));

end


function testDownsamplingTo5Hz(testCase)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    response = exp(-((t - 2).^2) / (2 * 0.5^2));
    onsets = [10 20 30];

    datafiles = testCase.createTestData(1, sr, duration, {response}, {onsets});

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    modelfile = [tempname '.mat'];
    testCase.addTeardown(@() pspm_tam_test.deleteIfExists(modelfile));

    model = struct();
    model.modelfile = modelfile;
    model.datafile = datafiles;
    model.timing = {timing};
    model.timeunits = 'seconds';
    model.window = window;
    model.modelspec = 'dilation';
    model.modality = 'pupil';
    model.channel = 'pupil';
    model.norm = 0;
    model.baseline = 0;
    model.norm_max = 0;
    model.filter = struct('lpfreq', 'none', 'lporder', 0, 'hpfreq', 'none', 'hporder', 0, 'down', 5, 'direction', 'bi');

    options.overwrite = 1;

    [sts, tam] = pspm_tam(model, options);

    testCase.assertEqual(sts, 1);

    expectedSize = [25 1];

    testCase.verifySize(tam.data.Y{1}, expectedSize);
    testCase.verifySize(tam.data.std{1}, expectedSize);
    testCase.verifySize(tam.data.sem{1}, expectedSize);
    testCase.verifySize(tam.data.X{1}, expectedSize);
    testCase.verifyEqual(tam.data.sr{1}, 5);

end


function testLowpassFilterWithoutDownsampling(testCase)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    response = exp(-((t - 2).^2) / (2 * 0.5^2)) + 0.1 * sin(2*pi*4*t);
    onsets = [10 20 30];

    datafiles = testCase.createTestData(1, sr, duration, {response}, {onsets});

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    modelfile = [tempname '.mat'];
    testCase.addTeardown(@() pspm_tam_test.deleteIfExists(modelfile));

    model = struct();
    model.modelfile = modelfile;
    model.datafile = datafiles;
    model.timing = {timing};
    model.timeunits = 'seconds';
    model.window = window;
    model.modelspec = 'dilation';
    model.modality = 'pupil';
    model.channel = 'pupil';
    model.norm = 0;
    model.baseline = 0;
    model.norm_max = 0;
    model.filter = struct('lpfreq', 1, 'lporder', 1, 'hpfreq', 'none', 'hporder', 0, 'down', 'none', 'direction', 'bi');

    options.overwrite = 1;

    [sts, tam] = pspm_tam(model, options);

    testCase.assertEqual(sts, 1);

    testCase.verifySize(tam.data.Y{1}, [50 1]);
    testCase.verifySize(tam.data.std{1}, [50 1]);
    testCase.verifySize(tam.data.sem{1}, [50 1]);
    testCase.verifySize(tam.data.X{1}, [50 1]);

    testCase.verifyEqual(tam.data.sr{1}, 10);
    testCase.verifyTrue(tam.data.filtered);

    expected_t = (1:50)' / sr;
    testCase.verifyEqual(tam.data.X{1}, expected_t, 'AbsTol', 1e-12);

    unfiltered = response - response(1);
    testCase.verifyGreaterThan(norm(tam.data.Y{1} - unfiltered), 1e-6);

end


function testTwoSessions(testCase)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    response1 = exp(-((t - 2).^2) / (2 * 0.5^2));
    response2 = 2 * response1;
    onsets = [10 20 30];

    datafiles = testCase.createTestData(2, sr, duration, {response1; response2}, {onsets});

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    modelfile = [tempname '.mat'];
    testCase.addTeardown(@() pspm_tam_test.deleteIfExists(modelfile));

    model = struct();
    model.modelfile = modelfile;
    model.datafile = datafiles;
    model.timing = {timing, timing};
    model.timeunits = 'seconds';
    model.window = window;
    model.modelspec = 'dilation';
    model.modality = 'pupil';
    model.channel = 'pupil';
    model.norm = 0;
    model.baseline = 0;
    model.norm_max = 0;
    model.filter = struct('lpfreq', 'none', 'lporder', 1, 'hpfreq', 'none', 'hporder', 1, 'down', 'none', 'direction', 'bi');

    options.overwrite = 1;

    [sts, tam] = pspm_tam(model, options);

    testCase.assertEqual(sts, 1);

    expected = (response1 + response2) / 2;
    expected = expected - expected(1);

    testCase.verifyEqual(tam.data.Y{1}, expected(:), 'AbsTol', 1e-10);
    testCase.verifyEqual(tam.data.sr, {10, 10});
    testCase.verifyEqual(numel(tam.data.Y), 1);

end


function testStandardExperimentalCondition(testCase, stdExpCond)

    sr = 10;
    duration = 60;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    baseResponse = exp(-((t - 2).^2) / (2 * 0.5^2));

    responseA = 0.5 * baseResponse;
    responseB = 2 * baseResponse;

    onsetsA = [10 30];
    onsetsB = [20 40];

    datafiles = testCase.createTestData(1, sr, duration, {responseA, responseB}, {onsetsA, onsetsB});

    timing.names = {'condition_A', 'condition_B'};
    timing.onsets = {onsetsA, onsetsB};
    timing.durations = {zeros(size(onsetsA)), zeros(size(onsetsB))};

    modelfile = [tempname '.mat'];
    testCase.addTeardown(@() pspm_tam_test.deleteIfExists(modelfile));

    model = struct();
    model.modelfile = modelfile;
    model.datafile = datafiles;
    model.timing = {timing};
    model.timeunits = 'seconds';
    model.window = window;
    model.modelspec = 'dilation';
    model.modality = 'pupil';
    model.channel = 'pupil';
    model.norm = 0;
    model.baseline = 0;
    model.norm_max = 0;
    model.std_exp_cond = stdExpCond;
    model.filter = struct('lpfreq', 'none', 'lporder', 1, 'hpfreq', 'none', 'hporder', 1, 'down', 'none', 'direction', 'bi');

    options.overwrite = 1;

    [sts, tam] = pspm_tam(model, options);

    testCase.assertEqual(sts, 1);

    expectedA = responseA - responseA(1);

    expectedB = responseB - responseA;
    expectedB = expectedB - expectedB(1);

    testCase.verifyEqual(tam.data.Y{1}, expectedA(:), 'AbsTol', 1e-10);
    testCase.verifyEqual(tam.data.Y{2}, expectedB(:), 'AbsTol', 1e-10);

    testCase.verifyEqual(tam.data.std_exp_cond.name, 'condition_A');
    testCase.verifyEqual(tam.data.std_exp_cond.ind, 1);

end


function testMarkerTimeunits(testCase, nFiles)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    response = exp(-((t - 2).^2) / (2 * 0.5^2));

    markerTimes = [10 20 30];

    datafiles = testCase.createTestData(nFiles, sr, duration, {response}, {markerTimes}, markerTimes);

    timing.names = {'condition_1'};
    timing.onsets = {[1 2 3]};
    timing.durations = {zeros(1,3)};

    modelfile = [tempname '.mat'];
    testCase.addTeardown(@() pspm_tam_test.deleteIfExists(modelfile));

    model = struct();
    model.modelfile = modelfile;
    model.datafile = datafiles;
    model.timing = repmat({timing}, 1, nFiles);
    model.timeunits = 'markers';
    model.window = window;
    model.modelspec = 'dilation';
    model.modality = 'pupil';
    model.channel = 'pupil';
    model.norm = 0;
    model.baseline = 0;
    model.norm_max = 0;
    model.filter = struct('lpfreq', 'none', 'lporder', 1, 'hpfreq', 'none', 'hporder', 1, 'down', 'none', 'direction', 'bi');

    options.overwrite = 1;
    options.marker_chan = 'marker';

    [sts, tam] = pspm_tam(model, options);

    testCase.assertEqual(sts, 1);

    expected = response - response(1);

    testCase.verifyEqual(tam.data.Y{1}, expected(:), 'AbsTol', 1e-10);
    testCase.verifyEqual(tam.data.sr, repmat({sr}, 1, nFiles));

end


function testZscoreNormalization(testCase)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    response = exp(-((t - 2).^2) / (2 * 0.5^2));
    onsets = [10 20 30];

    [datafiles, y] = testCase.createTestData(1, sr, duration, {response}, {onsets});
    y = y{1};

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    modelfile = [tempname '.mat'];
    testCase.addTeardown(@() pspm_tam_test.deleteIfExists(modelfile));

    model = struct();
    model.modelfile = modelfile;
    model.datafile = datafiles;
    model.timing = {timing};
    model.timeunits = 'seconds';
    model.window = window;
    model.modelspec = 'dilation';
    model.modality = 'pupil';
    model.channel = 'pupil';
    model.norm = 1;
    model.baseline = 0;
    model.norm_max = 0;
    model.filter = struct('lpfreq', 'none', 'lporder', 1, 'hpfreq', 'none', 'hporder', 1, 'down', 'none', 'direction', 'bi');

    options.overwrite = 1;

    [sts, tam] = pspm_tam(model, options);

    testCase.assertEqual(sts, 1);

    mu = mean(y, 'omitnan');
    sigma = std(y, 0, 'omitnan');

    expected = (response - mu) / sigma;
    expected = expected - expected(1);

    testCase.verifyEqual(tam.data.Y{1}, expected(:), 'AbsTol', 1e-10);
    testCase.verifyEqual(tam.data.norm, 1);

end


function testBaselineEqualWindowIsInvalid(testCase)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    response = exp(-((t - 2).^2) / (2 * 0.5^2));
    onsets = [10 20 30];

    datafiles = testCase.createTestData(1, sr, duration, {response}, {onsets});

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    modelfile = [tempname '.mat'];
    testCase.addTeardown(@() pspm_tam_test.deleteIfExists(modelfile));

    model = struct();
    model.modelfile = modelfile;
    model.datafile = datafiles;
    model.timing = {timing};
    model.timeunits = 'seconds';
    model.window = window;
    model.modelspec = 'dilation';
    model.modality = 'pupil';
    model.channel = 'pupil';
    model.norm = 0;
    model.baseline = window;
    model.norm_max = 0;

    options.overwrite = 1;

    testCase.verifyWarning(@() pspm_tam(model, options), 'ID:invalid_input');

end

end


methods (Access = private)

function [datafiles, signals] = createTestData(testCase, nFiles, sr, duration, responses, onsets, markerTimes)

    % responses:
    %   1 x nCond      -> same responses for all files
    %   nFiles x nCond -> different responses between files
    %
    % onsets:
    %   1 x nCond      -> same onsets for all files
    %   nFiles x nCond -> different onsets between files
    %
    % markerTimes:
    %   optional; [] means no marker channel

    if nargin < 7
        markerTimes = [];
    end

    if size(responses, 1) == 1 && nFiles > 1
        responses = repmat(responses, nFiles, 1);
    end

    if size(onsets, 1) == 1 && nFiles > 1
        onsets = repmat(onsets, nFiles, 1);
    end

    datafiles = cell(1, nFiles);
    signals = cell(1, nFiles);

    for k = 1:nFiles

        y = zeros(duration * sr, 1);

        for iCond = 1:size(responses, 2)

            response = responses{k, iCond};
            condOnsets = onsets{k, iCond};

            for iTrial = 1:numel(condOnsets)

                startSample = round(condOnsets(iTrial) * sr) + 1;
                stopSample = startSample + numel(response) - 1;

                y(startSample:stopSample) = y(startSample:stopSample) + response;

            end
        end

        signals{k} = y;

        data = cell(1, 1);
        data{1}.header = struct( 'chantype', 'pupil', 'sr', sr, 'units', 'a.u.');
        data{1}.data = y;

        if ~isempty(markerTimes)

            if iscell(markerTimes)
                thisMarkerTimes = markerTimes{k};
            else
                thisMarkerTimes = markerTimes;
            end

            data{2}.header = struct( 'chantype', 'marker', 'sr', 1, 'units', 'events');
            data{2}.data = thisMarkerTimes(:);

        end

        infos.duration = duration;
        infos.durationinfo = 'Duration in seconds';
        infos.source = struct();

        datafiles{k} = [tempname '.mat'];
        save(datafiles{k}, 'data', 'infos');

        testCase.addTeardown(@() pspm_tam_test.deleteIfExists(datafiles{k}));

    end

end

end


methods (Static, Access = private)

function deleteIfExists(filename)

    if exist(filename, 'file')
        delete(filename);
    end

end

end

end