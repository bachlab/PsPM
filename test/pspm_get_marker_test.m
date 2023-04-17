classdef pspm_get_marker_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_get_marker function
  % PsPM TestEnvironment
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  properties (TestParameter)
    flank = { 'descending', 'ascending' };
    sr = { 1, 2 };
  end
  methods (Test)
    function timestamps(this)
      import.sr = 1;
      import.data = 1:10;
      import.marker = 'timestamps';
      [sts, data] = pspm_get_marker(import);
      this.verifyEqual(sts, 1);
      this.verifyEqual(data.data, import.data(:));
      this.verifyTrue(strcmpi(data.header.chantype, 'marker'));
      this.verifyTrue(strcmpi(data.header.units, 'events'));
      this.verifyEqual(data.header.sr, 1);
    end
    function continuous(this, flank, sr)
      import.sr = sr;
      import.data = [ 42, 42, 84, 84, 84, 42, 42, 42, 84, 42 ];
      import.marker = 'continuous';
      import.flank = flank;
      [sts, data] = pspm_get_marker(import);
      expected = struct(...
        'descending', [ 6; 10 ], ...
        'ascending', [ 3; 9 ]...
        );
      this.verifyEqual(sts, 1);
      this.verifyEqual(data.data, expected.(flank) ./ sr);
      this.verifyTrue(strcmpi(data.header.chantype, 'marker'));
      this.verifyTrue(strcmpi(data.header.units, 'events'));
      this.verifyEqual(data.header.sr, 1);
    end
  end
end