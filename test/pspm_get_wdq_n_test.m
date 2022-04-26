classdef pspm_get_wdq_n_test < pspm_get_superclass
  % ● Description
  % unittest class for the pspm_get_wdq_n function
  % PsPM 3.0 TestEnvironment
  % ● Authorship
  % (C) 2014 Tobias Moser (University of Zurich)
  properties
    testcases;
    fhandle = @pspm_get_wdq_n
  end
  methods
    function define_testcases(this)
      % only testcase at the moment since this is the only kind of
      % data we are able to produce
      % testcase 1
      this.testcases{1}.pth = 'ImportTestData/nwdq/sc4b26.WDQ';
      this.testcases{1}.import{1} = struct('type', 'scr', 'channel', 1);
      this.testcases{1}.import{2} = struct('type', 'ecg', 'channel', 2);
      this.testcases{1}.import{3} = struct('type', 'ecg', 'channel', 3);
      this.testcases{1}.import{4} = struct('type', 'resp', 'channel', 4);
      this.testcases{1}.import{5} = struct('type', 'marker', 'channel', 5);
    end
  end
  methods (Test)
    function invalid_input(this)
      fn = 'ImportTestData/nwdq/sc4b26.WDQ';
      import{1} = struct('type', 'scr'   , 'channel', 1);
      import{2} = struct('type', 'marker', 'channel', 7);
      import = this.assign_chantype_number(import);
      this.verifyWarning(@()pspm_get_wdq_n(fn, import), 'ID:channel_not_contained_in_file');
    end
  end
end