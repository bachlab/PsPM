classdef pspm_logical2epochs_test < matlab.unittest.TestCase
    % unittest class for the pspm_logical2epochs function
    % PsPM TestEnvironment
    % ● Authorship
    % (C) 2024 Bernhard Agoué von Raußendorf 

    methods (TestMethodSetup)
        function addFunctionPath(testCase)
            % Add the path to the source directory
            srcPath = fullfile(pwd, '..', 'src');
            addpath(srcPath);
        end
    end

    methods (TestMethodTeardown)
        function removeFunctionPath(testCase)
            % Remove the path to the source directory after each test
            srcPath = fullfile(pwd, '..', 'src');
            rmpath(srcPath);
        end
    end

    methods (Test)
        function testBasicFunctionality(testCase)
            index = double([0; 1; 1; 0; 0; 1; 0; 0; 0; 0]);
            sr = 1;
            expectedOutput = [2, 4; 6, 7];
            actualOutput = pspm_logical2epochs(index, sr);
            testCase.verifyEqual(actualOutput, expectedOutput);
        end
       

        function testWithSampleRateConversion(testCase)
            index = double([0; 0; 1; 0; 1; 0; 0; 0; 0; 0]);
            sr = 2;
            expectedOutput = [1, 1.5; 2, 2.5];
            actualOutput = pspm_logical2epochs(index, sr);
            testCase.verifyEqual(actualOutput, expectedOutput);
        end

    end
end
