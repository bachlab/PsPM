classdef pspm_epochs2logical_test < matlab.unittest.TestCase
    % unittest class for the pspm_epochs2logical function
    % PsPM TestEnvironment
    % ● Authorship
    % (C) 2024 Abdul Wahab Madni (University of Bonn)
    methods (TestMethodSetup)
        function addFunctionPath(testCase)
            % Add the path to the source directory
            srcPath = fullfile(pwd, '..', 'src');
            addpath(srcPath);
        end
    end

    methods (TestMethodTeardown)
        function removeFunctionPath(testCase)
            % Remove the path to the source directory
            srcPath = fullfile(pwd, '..', 'src');
            rmpath(srcPath);
        end
    end
    methods (Test)
        function testBasicFunctionality(testCase)
            epochs = [2, 4; 6, 7];
            datalength = 10;
            sr = 1;
            expectedOutput = double([0; 1; 1; 0; 0; 1; 0; 0; 0; 0]);
            actualOutput = pspm_epochs2logical(epochs, datalength, sr);
            testCase.verifyEqual(actualOutput, expectedOutput);
        end

        function testOverlappingEpochs(testCase)
            epochs = [1, 3; 2, 5];
            datalength = 6;
            sr = 1;
            expectedOutput = double([1; 1; 1; 1; 0; 0]);
            actualOutput = pspm_epochs2logical(epochs, datalength, sr);
            testCase.verifyEqual(actualOutput, expectedOutput);
        end

        function testEpochsBeyondDataLength(testCase)
            epochs = [8, 12];
            datalength = 10;
            sr = 1;
            expectedOutput = double([0; 0; 0; 0; 0; 0; 0; 1; 1; 1]);
            actualOutput = pspm_epochs2logical(epochs, datalength, sr);
            testCase.verifyEqual(actualOutput, expectedOutput);
        end

        function testWithSampleRateConversion(testCase)
            epochs = [1, 1.5; 2, 2.5];
            datalength = 10;
            sr = 2; % Indicates conversion is needed
            expectedOutput = double([0; 0; 1; 0; 1; 0; 0; 0; 0; 0]);
            actualOutput = pspm_epochs2logical(epochs, datalength, sr);
            testCase.verifyEqual(actualOutput, expectedOutput);
        end

        function test_epoch_duration(testCase)
            % test that generated epochs have the right duration
            epochs = [1.2,5.6];
            datalength = 200;
            samplerates = 2:23;
            for k = 1:numel(samplerates)
                sr = samplerates(k);
                index = pspm_epochs2logical(epochs, datalength, sr);
                actual_index_length = sum(index);
                expected_index_length = diff(round(sr * epochs), 1, 2);
                testCase.verifyEqual(actual_index_length, expected_index_length);
                if ~(actual_index_length==expected_index_length), keyboard; end
            end
        end
    end
end