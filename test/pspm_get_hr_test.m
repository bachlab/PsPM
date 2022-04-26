classdef pspm_get_hr_test < matlab.unittest.TestCase
  % SCR_GET_HR_TEST
  % unittest class for the pspm_get_hr function
  % PsPM TestEnvironment
  % (C) 2013 Linus Rüttimann (University of Zurich)
  methods (Test)
    function test(this)
      import.sr = 100;
      import.data = ones(1,1000);
      import.units = 'unit';
      [sts, data] = pspm_get_hr(import);
      this.verifyEqual(sts, 1);
      this.verifyEqual(data.data, import.data(:));
      this.verifyTrue(strcmpi(data.header.chantype, 'hr'));
      this.verifyEqual(data.header.units, import.units);
      this.verifyEqual(data.header.sr, import.sr);
    end
  end
end