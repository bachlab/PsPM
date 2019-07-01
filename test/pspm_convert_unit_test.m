classdef pspm_convert_unit_test < matlab.unittest.TestCase
    % PSPM_CONVERT_UNIT_TEST
    % unittest class for the pspm_convert_unit function
    %__________________________________________________________________________
    % (C) 2019 Eshref Yozdemir (University of Zurich)
    properties(Constant)
        inch_to_cm = 2.54;
    end

    methods
        function test_success(this, input_arr, expected_arr, from, to)
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance
            [sts, actual_arr] = pspm_convert_unit(input_arr, from, to);
            this.verifyEqual(sts, 1);
            this.verifyThat(actual_arr, IsEqualTo(expected_arr, 'Within', RelativeTolerance(1e-10)));
        end
    end

    methods(Test)
        function invalid_input(testCase)
            % Nonnumeric input
            testCase.verifyWarning(@()pspm_convert_unit('012345', 'cm', 'cm'), 'ID:invalid_input', 'invalid_inputargs test 2');
            % Unallowed units
            testCase.verifyWarning(@()pspm_convert_unit(1:10, 'ABC', 'cm'), 'ID:invalid_input', 'invalid_inputargs test 3');
            testCase.verifyWarning(@()pspm_convert_unit(1:10, 'cm', 'DEF'), 'ID:invalid_input', 'invalid_inputargs test 4');
            testCase.verifyWarning(@()pspm_convert_unit(1:10, 5, 6), 'ID:invalid_input', 'invalid_inputargs test 5');
            testCase.verifyWarning(@()pspm_convert_unit(1:10, [5, 6], 'km'), 'ID:invalid_input', 'invalid_inputargs test 6');
        end

        function valid_input(this)
            % Empty input
            [sts, converted] = pspm_convert_unit([], 'cm', 'km');
            this.verifyTrue(sts == 1 && isempty(converted));
            % One element
            this.test_success([1.0], [1e-2], 'cm', 'm');
            this.test_success(1.0, 1e-2, 'cm', 'm');
            % Various unit checks
            this.test_success([12.0], [12.0], 'cm', 'cm');
            this.test_success([5.0], [5e-6], 'mm', 'km');
            this.test_success([72.32], [72.32e3], 'km', 'm');
            this.test_success([1e-5], [this.inch_to_cm*1e-5], 'inches', 'cm');
            this.test_success([1e-5], [this.inch_to_cm*1e-5], 'in', 'cm');
            this.test_success([this.inch_to_cm*1e5], [this.inch_to_cm*1e5], 'in', 'inches');
            % Negative values
            this.test_success([-5], [-5e3], 'm', 'mm');
            this.test_success([-5], [this.inch_to_cm*(-5)], 'inches', 'cm');
            % Multiple values
            this.test_success([5 -6 7], [500 -600 700], 'm', 'cm');
            e = exp(1);
            this.test_success([pi e], [1e5*pi/this.inch_to_cm, 1e5*e/this.inch_to_cm], 'km', 'inches');
            % Multidimensional arrays
            this.test_success(reshape(1:120, 3, 4, 10), 1e-5*reshape(1:120, 3, 4, 10), 'cm', 'km');
        end
    end
end
