classdef pspm_get_hb_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_get_hb function
  % PsPM TestEnvironment
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  methods (Test)
    function test(this)
      import.sr = 1;
      import.data = 1:10;
      import.marker = 'timestamps';
      [sts, data] = pspm_get_hb(import);
      this.verifyEqual(sts, 1);
      this.verifyEqual(data.data, import.data(:));
      this.verifyTrue(strcmpi(data.header.channeltype, 'hb'));
      this.verifyTrue(strcmpi(data.header.units, 'events'));
      this.verifyEqual(data.header.sr, 1);
    end
  end
end