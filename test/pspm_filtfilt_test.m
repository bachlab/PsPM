classdef pspm_filtfilt_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_hb2hp function
  % ● Authorship
  % (C) 2019 Ivan Rojkov (University of Zurich)
  methods (Test)
    function invalid_input(this)
      % Verify no input
      this.verifyWarning(@() pspm_filtfilt(), 'ID:invalid_input');
      % Verify that data must have length more than 3 times filter order.
      this.verifyWarning(@() pspm_filtfilt([1:10],[1:20],[1:10]), 'ID:invalid_input');
    end
  end
end