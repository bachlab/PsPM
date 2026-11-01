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

    datafiles = testCase.createTestData( nFiles, sr, duration, {response}, {onsets});

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    timings = repmat({timing}, 1, nFiles);

    [model, options] = testCase.createDefaultModel(datafiles, timings, window);

    tam = testCase.runTam(model, options);

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

    [model, options] = testCase.createDefaultModel( datafiles, {timing}, window);

    model.filter = struct( 'lpfreq', 'none', 'lporder', 0, 'hpfreq', 'none', 'hporder', 0, 'down', 5, 'direction', 'bi');

    tam = testCase.runTam(model, options);

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

    datafiles = testCase.createTestData( 1, sr, duration, {response}, {onsets});

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    [model, options] = testCase.createDefaultModel( datafiles, {timing}, window);

    model.filter = struct( 'lpfreq', 1, 'lporder', 1, 'hpfreq', 'none', 'hporder', 0, 'down', 'none', 'direction', 'bi');

    tam = testCase.runTam(model, options);

    testCase.verifySize(tam.data.Y{1}, [50 1]);
    testCase.verifySize(tam.data.std{1}, [50 1]);
    testCase.verifySize(tam.data.sem{1}, [50 1]);
    testCase.verifySize(tam.data.X{1}, [50 1]);

    testCase.verifyEqual(tam.data.sr{1}, 10);
    testCase.verifyTrue(tam.data.filtered);

    expected_t = (1:50)' / sr;

    testCase.verifyEqual(tam.data.X{1}, expected_t, 'AbsTol', 1e-12);

    unfiltered = response - response(1);

    testCase.verifyGreaterThan( norm(tam.data.Y{1} - unfiltered), 1e-6);

end


function testTwoSessions(testCase)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';

    response1 = exp(-((t - 2).^2) / (2 * 0.5^2));
    response2 = 2 * response1;

    onsets = [10 20 30];

    datafiles = testCase.createTestData( 2, sr, duration, {response1; response2}, {onsets});

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    timings = {timing, timing};

    [model, options] = testCase.createDefaultModel( datafiles, timings, window);

    tam = testCase.runTam(model, options);

    expected = (response1 + response2) / 2;
    expected = expected - expected(1);

    testCase.verifyEqual( tam.data.Y{1}, expected(:), 'AbsTol', 1e-10);

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

    datafiles = testCase.createTestData( 1, sr, duration, {responseA, responseB}, {onsetsA, onsetsB});

    timing.names = {'condition_A', 'condition_B'};
    timing.onsets = {onsetsA, onsetsB};
    timing.durations = { zeros(size(onsetsA)), zeros(size(onsetsB))};

    [model, options] = testCase.createDefaultModel( datafiles, {timing}, window);

    model.std_exp_cond = stdExpCond;

    tam = testCase.runTam(model, options);

    expectedA = responseA - responseA(1);

    expectedB = responseB - responseA;
    expectedB = expectedB - expectedB(1);

    testCase.verifyEqual( tam.data.Y{1}, expectedA(:), 'AbsTol', 1e-10);

    testCase.verifyEqual( tam.data.Y{2}, expectedB(:), 'AbsTol', 1e-10);

    testCase.verifyEqual( tam.data.std_exp_cond.name, 'condition_A');

    testCase.verifyEqual( tam.data.std_exp_cond.ind, 1);

end


function testMarkerTimeunits(testCase, nFiles)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    response = exp(-((t - 2).^2) / (2 * 0.5^2));

    markerTimes = [10 20 30];

    datafiles = testCase.createTestData( nFiles, sr, duration, {response}, {markerTimes}, markerTimes);

    timing.names = {'condition_1'};
    timing.onsets = {[1 2 3]};
    timing.durations = {zeros(1,3)};

    timings = repmat({timing}, 1, nFiles);

    [model, options] = testCase.createDefaultModel( datafiles, timings, window);

    model.timeunits = 'markers';
    options.marker_chan = 'marker';

    tam = testCase.runTam(model, options);

    expected = response - response(1);

    testCase.verifyEqual( tam.data.Y{1}, expected(:), 'AbsTol', 1e-10);

    testCase.verifyEqual( tam.data.sr, repmat({sr}, 1, nFiles));

end


function testZscoreNormalization(testCase)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    response = exp(-((t - 2).^2) / (2 * 0.5^2));

    onsets = [10 20 30];

    [datafiles, signals] = testCase.createTestData( 1, sr, duration, {response}, {onsets});

    y = signals{1};

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    [model, options] = testCase.createDefaultModel( datafiles, {timing}, window);

    model.norm = 1;

    tam = testCase.runTam(model, options);

    mu = mean(y, 'omitnan');
    sigma = std(y, 0, 'omitnan');

    expected = (response - mu) / sigma;
    expected = expected - expected(1);

    testCase.verifyEqual( tam.data.Y{1}, expected(:), 'AbsTol', 1e-10);

    testCase.verifyEqual(tam.data.norm, 1);

end


function testBaselineEqualWindowIsInvalid(testCase)

    sr = 10;
    duration = 50;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    response = exp(-((t - 2).^2) / (2 * 0.5^2));

    onsets = [10 20 30];

    datafiles = testCase.createTestData( 1, sr, duration, {response}, {onsets});

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    [model, options] = testCase.createDefaultModel( datafiles, {timing}, window);

    model.baseline = window;

    testCase.verifyWarning( @() pspm_tam(model, options), 'ID:invalid_input');

end


function testThreeSessionsWithTimingFiles(testCase)

    sr = 10;
    duration = 50;
    window = 5;
    nSessions = 3;

    t = (0:1/sr:window-1/sr)';
    response = exp(-((t - 2).^2) / (2 * 0.5^2));
    onsets = [10 20 30];

    datafiles = testCase.createTestData( ...
        nSessions, sr, duration, {response}, {onsets});

    timing.names = {'condition_1'};
    timing.onsets = {onsets};
    timing.durations = {zeros(size(onsets))};

    timings = repmat({timing}, 1, nSessions);

    timingfiles = testCase.createTimingFiles(timings);

    [model, options] = testCase.createDefaultModel( ...
        datafiles, timingfiles, window);

    tam = testCase.runTam(model, options);

    testCase.verifyEqual(tam.names, {'condition_1'});
    testCase.verifyEqual(tam.timing, timingfiles);
    testCase.verifyEqual( ...
        tam.data.sr, repmat({sr}, 1, nSessions));

end

function testTwoSessionsTwoConditions(testCase)

    sr = 10;
    duration = 60;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    baseResponse = exp(-((t - 2).^2) / (2 * 0.5^2));

    responseA1 = 1 * baseResponse;
    responseB1 = 2 * baseResponse;

    responseA2 = 3 * baseResponse;
    responseB2 = 4 * baseResponse;

    onsetsA1 = [10 30];
    onsetsB1 = [20 40];

    onsetsA2 = [12 32];
    onsetsB2 = [22 42];

    responses = {
        responseA1, responseB1
        responseA2, responseB2
        };

    onsets = {
        onsetsA1, onsetsB1
        onsetsA2, onsetsB2
        };

    datafiles = testCase.createTestData( 2, sr, duration, responses, onsets);

    timing1.names = {'condition_A', 'condition_B'};
    timing1.onsets = {onsetsA1, onsetsB1};
    timing1.durations = {zeros(size(onsetsA1)), zeros(size(onsetsB1))};

    timing2.names = {'condition_A', 'condition_B'};
    timing2.onsets = {onsetsA2, onsetsB2};
    timing2.durations = {zeros(size(onsetsA2)), zeros(size(onsetsB2))};

    [model, options] = testCase.createDefaultModel( datafiles, {timing1, timing2}, window);

    tam = testCase.runTam(model, options);

    expectedA = (responseA1 + responseA2) / 2;
    expectedA = expectedA - expectedA(1);

    expectedB = (responseB1 + responseB2) / 2;
    expectedB = expectedB - expectedB(1);

    testCase.verifyEqual( tam.names, {'condition_A', 'condition_B'});

    testCase.verifyEqual( tam.data.Y{1}, expectedA(:), 'AbsTol', 1e-10);

    testCase.verifyEqual( tam.data.Y{2}, expectedB(:), 'AbsTol', 1e-10);

    testCase.verifyEqual(tam.data.sr, {sr, sr});

end

function testConditionOrderDiffersAcrossSessions(testCase)

    sr = 10;
    duration = 60;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    baseResponse = exp(-((t - 2).^2) / (2 * 0.5^2));

    responseA1 = 1 * baseResponse;
    responseB1 = 2 * baseResponse;

    responseA2 = 3 * baseResponse;
    responseB2 = 4 * baseResponse;

    onsetsA1 = [10 30];
    onsetsB1 = [20 40];

    onsetsA2 = [12 32];
    onsetsB2 = [22 42];

    % Session 1: A, B
    % Session 2: B, A
    responses = {
        responseA1, responseB1
        responseB2, responseA2
        };

    onsets = {
        onsetsA1, onsetsB1
        onsetsB2, onsetsA2
        };

    datafiles = testCase.createTestData( 2, sr, duration, responses, onsets);

    timing1.names = {'condition_A', 'condition_B'};
    timing1.onsets = {onsetsA1, onsetsB1};
    timing1.durations = {zeros(size(onsetsA1)), zeros(size(onsetsB1))};

    timing2.names = {'condition_B', 'condition_A'};
    timing2.onsets = {onsetsB2, onsetsA2};
    timing2.durations = {zeros(size(onsetsB2)), zeros(size(onsetsA2))};

    [model, options] = testCase.createDefaultModel( ...
        datafiles, {timing1, timing2}, window);

    tam = testCase.runTam(model, options);

    % Conditions should be matched by NAME, not by position.
    expectedA = (responseA1 + responseA2) / 2;
    expectedA = expectedA - expectedA(1);

    expectedB = (responseB1 + responseB2) / 2;
    expectedB = expectedB - expectedB(1);

    testCase.verifyEqual( ...
        tam.names, {'condition_A', 'condition_B'});

    testCase.verifyEqual( ...
        tam.data.Y{1}, expectedA(:), 'AbsTol', 1e-10);

    testCase.verifyEqual( ...
        tam.data.Y{2}, expectedB(:), 'AbsTol', 1e-10);

end

function testConditionMissingInSecondSession(testCase)

    sr = 10;
    duration = 60;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    baseResponse = exp(-((t - 2).^2) / (2 * 0.5^2));

    responseA1 = 1 * baseResponse;
    responseB1 = 2 * baseResponse;

    responseA2 = 3 * baseResponse;
    responseB2 = 4 * baseResponse;

    onsetsA1 = [10 30];
    onsetsB1 = [20 40];

    onsetsA2 = [12 32];
    onsetsB2 = [];

    responses = {
        responseA1, responseB1
        responseA2, responseB2
        };

    onsets = {
        onsetsA1, onsetsB1
        onsetsA2, onsetsB2
        };

    datafiles = testCase.createTestData(2, sr, duration, responses, onsets);

    timing1.names = {'condition_A', 'condition_B'};
    timing1.onsets = {onsetsA1, onsetsB1};
    timing1.durations = {zeros(size(onsetsA1)), zeros(size(onsetsB1))};

    timing2.names = {'condition_A', 'condition_B'};
    timing2.onsets = {onsetsA2, onsetsB2};
    timing2.durations = {zeros(size(onsetsA2)), zeros(size(onsetsB2))};

    [model, options] = testCase.createDefaultModel(datafiles, {timing1, timing2}, window);

    tam = testCase.runTam(model, options);

    % A exists in both sessions.
    expectedA = (responseA1 + responseA2) / 2;
    expectedA = expectedA - expectedA(1);

    % B exists only in session 1.
    % Session 2 must therefore not contribute a zero response.
    expectedB = responseB1;
    expectedB = expectedB - expectedB(1);

    testCase.verifyEqual( tam.names, {'condition_A', 'condition_B'});

    testCase.verifyEqual( tam.data.Y{1}, expectedA(:), 'AbsTol', 1e-10);

    testCase.verifyEqual( tam.data.Y{2}, expectedB(:), 'AbsTol', 1e-10);

end
function testConditionAbsentFromSecondSession(testCase)

    sr = 10;
    duration = 60;
    window = 5;

    t = (0:1/sr:window-1/sr)';
    baseResponse = exp(-((t - 2).^2) / (2 * 0.5^2));

    responseA1 = 1 * baseResponse;
    responseB1 = 2 * baseResponse;
    responseA2 = 3 * baseResponse;

    onsetsA1 = [10 30];
    onsetsB1 = [20 40];
    onsetsA2 = [12 32];

    %% Session 1: A and B
    datafile1 = testCase.createTestData( ...
        1, sr, duration, ...
        {responseA1, responseB1}, ...
        {onsetsA1, onsetsB1});

    %% Session 2: only A
    datafile2 = testCase.createTestData( ...
        1, sr, duration, ...
        {responseA2}, ...
        {onsetsA2});

    datafiles = {datafile1{1}, datafile2{1}};

    %% Session 1 timing: A and B
    timing1.names = {'condition_A', 'condition_B'};
    timing1.onsets = {onsetsA1, onsetsB1};
    timing1.durations = { ...
        zeros(size(onsetsA1)), ...
        zeros(size(onsetsB1))};

    %% Session 2 timing: only A
    timing2.names = {'condition_A'};
    timing2.onsets = {onsetsA2};
    timing2.durations = {zeros(size(onsetsA2))};

    [model, options] = testCase.createDefaultModel( ...
        datafiles, {timing1, timing2}, window);

    tam = testCase.runTam(model, options);

    %% Expected condition A:
    % present in both sessions
    expectedA = (responseA1 + responseA2) / 2;
    expectedA = expectedA - expectedA(1);

    %% Expected condition B:
    % present only in session 1
    expectedB = responseB1;
    expectedB = expectedB - expectedB(1);

    testCase.verifyEqual( ...
        tam.names, {'condition_A', 'condition_B'});

    testCase.verifyEqual( ...
        tam.data.Y{1}, expectedA(:), 'AbsTol', 1e-10);

    testCase.verifyEqual( ...
        tam.data.Y{2}, expectedB(:), 'AbsTol', 1e-10);

    testCase.verifyEqual( ...
        tam.data.sr, {sr, sr});

end 
end


%% helper functions
methods (Access = private)

function [model, options] = createDefaultModel( testCase, datafiles, timing, window)

modelfile = [tempname '.mat'];

testCase.addTeardown( @() pspm_tam_test.deleteIfExists(modelfile));

model = struct();

model.modelfile = modelfile;
model.datafile = datafiles;
model.timing = timing;

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

options = struct();
options.overwrite = 1;

end


function tam = runTam(testCase, model, options)

[sts, tam] = pspm_tam(model, options);

testCase.assertEqual(sts, 1);

end


function timingfiles = createTimingFiles(testCase, timings)

timingfiles = cell(size(timings));

for k = 1:numel(timings)

    timing = timings{k};

    timingfiles{k} = [tempname '.mat'];

    save(timingfiles{k}, '-struct', 'timing');

    testCase.addTeardown( ...
        @() pspm_tam_test.deleteIfExists(timingfiles{k}));

end

end


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

        y(startSample:stopSample) =  y(startSample:stopSample) + response;

    end

end

signals{k} = y;

data = cell(1, 1);
data{1}.header = struct('chantype', 'pupil', 'sr', sr, 'units', 'a.u.');
data{1}.data = y;

if ~isempty(markerTimes)

    if iscell(markerTimes)
        thisMarkerTimes = markerTimes{k};
    else
        thisMarkerTimes = markerTimes;
    end

    data{2}.header = struct('chantype', 'marker', 'sr', 1, 'units', 'events');
    data{2}.data = thisMarkerTimes(:);

end

infos.duration = duration;
infos.durationinfo = 'Duration in seconds';
infos.source = struct();

datafiles{k} = [tempname '.mat'];

save(datafiles{k}, 'data', 'infos');

testCase.addTeardown( @() pspm_tam_test.deleteIfExists(datafiles{k}));

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