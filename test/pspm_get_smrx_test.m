classdef pspm_get_smrx_test < pspm_get_superclass
  % ● Description
  %   unittest class for the pspm_get_smrx function
  % ● History
  %   Written in 2023 by Teddy
  properties
    testcases;
    fhandle = @pspm_get_smrx;
    datatype = 'spike';
  end
  methods
    function define_testcases(this)
      % testcase 1
      this.testcases{1}.pth = 'ImportTestData/spike/25Oct2023.smrx';
      this.testcases{1}.import{1} = struct('type', 'scr'   , 'channel', 1);
      this.testcases{1}.import{2} = struct('type', 'marker', 'channel', 2);
      this.testcases{1}.import{3} = struct('type', 'marker', 'channel', 3);
      this.testcases{1}.import{4} = struct('type', 'marker', 'channel', 4);
      this.testcases{1}.import{5} = struct('type', 'marker', 'channel', 5);
      this.testcases{1}.import{6} = struct('type', 'marker', 'channel', 6);
      this.testcases{1}.import{7} = struct('type', 'marker', 'channel', 7);
      % this.testcases{1}.import{8} = struct('type', 'marker', 'channel', 8);
      % this.testcases{1}.import{9} = struct('type', 'marker', 'channel', 9);
    end
  end
  methods (Test)
    function invalid_datafile(this)
      fn = 'ImportTestData/spike/25Oct2023.smrx';
      import{1} = struct('type', 'scr'   , 'channel', 1);
      import{2} = struct('type', 'marker', 'channel', 2);
      import{3} = struct('type', 'marker', 'channel', 4);
      import = this.assign_chantype_number(import);
      this.verifyWarning(@()pspm_get_smrx(fn, import), 'ID:channel_not_contained_in_file');
    end
  end
end
