classdef pspm_get_ecg_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_get_ecg function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  methods (Test)
    function test(this)
      import.sr = 100;
      import.data = ones(1,1000);
      import.units = 'unit';
      [sts, data] = pspm_get_ecg(import);
      this.verifyEqual(sts, 1);
      this.verifyEqual(data.data, import.data(:));
      this.verifyTrue(strcmpi(data.header.chantype, 'ecg'));
      this.verifyEqual(data.header.units, import.units);
      this.verifyEqual(data.header.sr, import.sr);
    end
  end
end