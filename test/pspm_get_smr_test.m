classdef pspm_get_smr_test < pspm_get_superclass
  % ● Description
  % unittest class for the pspm_get_smr function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  properties
    testcases;
    fhandle = @pspm_get_smr;
    datatype = 'spike';
  end
  methods
    function define_testcases(this)
      % testcase 1
      this.testcases{1}.pth = 'ImportTestData/spike/AEC_11.smr';
      this.testcases{1}.import{1} = struct('type', 'scr'   , 'channel', 1);
      this.testcases{1}.import{2} = struct('type', 'marker', 'channel', 2);
      this.testcases{1}.import{3} = struct('type', 'marker', 'channel', 3);
      this.testcases{1}.import{4} = struct('type', 'marker', 'channel', 4);
      this.testcases{1}.import{5} = struct('type', 'marker', 'channel', 5);
      this.testcases{1}.import{6} = struct('type', 'marker', 'channel', 6);
      this.testcases{1}.import{7} = struct('type', 'marker', 'channel', 7);
      % this.testcases{1}.import{8} = struct('type', 'marker', 'channel', 8);
      % this.testcases{1}.import{9} = struct('type', 'marker', 'channel', 9);
      % testcase 2
      this.testcases{2}.pth = 'ImportTestData/spike/Spike_SCR_Marker.smr';
      this.testcases{2}.import{1} = struct('type', 'scr'   , 'channel', 1);
      this.testcases{2}.import{2} = struct('type', 'marker', 'channel', 2);
    end
  end
  methods (Test)
    function invalid_datafile(this)
      fn = 'ImportTestData/spike/Spike_SCR_Marker.smr';
      import{1} = struct('type', 'scr'   , 'channel', 1);
      import{2} = struct('type', 'marker', 'channel', 2);
      import{3} = struct('type', 'marker', 'channel', 4);
      import = this.assign_chantype_number(import);
      this.verifyWarning(@()pspm_get_smr(fn, import), 'ID:channel_not_contained_in_file');
    end
  end
end
