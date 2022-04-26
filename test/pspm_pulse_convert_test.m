classdef pspm_pulse_convert_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_pulse_convert function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  methods (Test)
    function invalid_input(testCase)
      testCase.verifyWarning(@()pspm_pulse_convert, 'ID:invalid_input', 'invalid_inputargs test 1');
      testCase.verifyWarning(@()pspm_pulse_convert(10^-3 * (1:10000)'), 'ID:invalid_input', 'invalid_inputargs test 2');
      testCase.verifyWarning(@()pspm_pulse_convert(10^-3 * (1:10000)', 10000), 'ID:invalid_input', 'invalid_inputargs test 3');
    end
    function valid_input(testCase)
      % generate test data
      sr = 10^4;
      t = sr^-1:sr^-1:10;
      d = [2, 3, 4.55, 4.66, 4.67, 5, 6, 7, 8, 9.9];
      pulswave = pulstran(t, d, 'rectpuls', 0.1);
      [pks, locs] = findpeaks(pulswave);
      pulsdata = t(locs);
      % test without downsampling (which causes a pspm_prepdata call -> data will be filtered too)
      testCase.verifyWarningFree(@()pspm_pulse_convert(pulsdata, sr, sr));
      % test with downsampling
      testCase.verifyWarningFree(@()pspm_pulse_convert(pulsdata, sr, sr/10));
    end
  end
end