classdef pspm_convert_pixel2unit_core_test < matlab.unittest.TestCase
% Unit tests for pspm_convert_pixel2unit_core
% ● Description
% unittest class for the pspm_convert_ecg2hb function
% ● Authorship
% (C) 2026 Bernhard von Raußendorf (University of Bonn)
methods (Test)
 
function testBasicConversion(testCase)
    data = [1 401 801];
    data_range = [1 801];
    screen_length = 400; % mm

    [out_data, out_range] = pspm_convert_pixel2unit_core(data, data_range, screen_length);

    expected_length_per_pixel = 400 / (801 - 1 + 1); % 400/801
    expected_out_data = [0 400 800] * expected_length_per_pixel;
    expected_out_range = [0 800] * expected_length_per_pixel;

    testCase.verifyEqual(out_data, expected_out_data, 'AbsTol', 1e-12);
    testCase.verifyEqual(out_range, expected_out_range, 'AbsTol', 1e-12);
end

function testScalarData(testCase)
    data = 51;
    data_range = [1 101];
    screen_length = 500;

    [out_data, out_range] = pspm_convert_pixel2unit_core(data, data_range, screen_length);

    expected_length_per_pixel = 500 / (101 - 1 + 1); % 500/101
    expected_out_data = (51 - 1) * expected_length_per_pixel;
    expected_out_range = [0 100] * expected_length_per_pixel;

    testCase.verifyEqual(out_data, expected_out_data, 'AbsTol', 1e-12);
    testCase.verifyEqual(out_range, expected_out_range, 'AbsTol', 1e-12);
end

function testNegativeAndOffsetRange(testCase)
    data = [-100 0 100];
    data_range = [-200 200];
    screen_length = 600;

    [out_data, out_range] = pspm_convert_pixel2unit_core(data, data_range, screen_length);

    expected_length_per_pixel = 600 / (200 - (-200) + 1); % 600/401
    expected_out_data = ([100 200 300]) * expected_length_per_pixel;
    expected_out_range = [0 400] * expected_length_per_pixel;

    testCase.verifyEqual(out_data, expected_out_data, 'AbsTol', 1e-12);
    testCase.verifyEqual(out_range, expected_out_range, 'AbsTol', 1e-12);
end

function testRangeEndpoints(testCase)
    data = [10 20];
    data_range = [10 20];
    screen_length = 110;

    [out_data, out_range] = pspm_convert_pixel2unit_core(data, data_range, screen_length);

    expected_length_per_pixel = 110 / (20 - 10 + 1); % 110/11
    expected_out_data = [0 10] * expected_length_per_pixel;
    expected_out_range = [0 10] * expected_length_per_pixel;

    testCase.verifyEqual(out_data, expected_out_data, 'AbsTol', 1e-12);
    testCase.verifyEqual(out_range, expected_out_range, 'AbsTol', 1e-12);
end

function testColumnVectorPreserved(testCase)
    data = [1; 6; 11];
    data_range = [1 11];
    screen_length = 55;

    [out_data, out_range] = pspm_convert_pixel2unit_core(data, data_range, screen_length);

    expected_length_per_pixel = 55 / (11 - 1 + 1); % 55/11
    expected_out_data = [0; 5; 10] * expected_length_per_pixel;
    expected_out_range = [0 10] * expected_length_per_pixel;

    testCase.verifyEqual(out_data, expected_out_data, 'AbsTol', 1e-12);
    testCase.verifySize(out_data, size(data));
    testCase.verifyEqual(out_range, expected_out_range, 'AbsTol', 1e-12);
end

function testSinglePixelRange(testCase)
    data = 5;
    data_range = [5 5];
    screen_length = 20;

    [out_data, out_range] = pspm_convert_pixel2unit_core(data, data_range, screen_length);

    % diff([5 5]) + 1 = 1
    expected_length_per_pixel = 20;
    expected_out_data = 0;
    expected_out_range = [0 0];

    testCase.verifyEqual(out_data, expected_out_data, 'AbsTol', 1e-12);
    testCase.verifyEqual(out_range, expected_out_range, 'AbsTol', 1e-12);
end
end
end