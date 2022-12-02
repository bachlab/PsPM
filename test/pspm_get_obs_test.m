classdef pspm_get_obs_test < pspm_get_superclass
  % ● Description
  % unittest class for the pspm_get_obs function
  % PsPM TestEnvironment
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  properties
    testcases;
    fhandle = @pspm_get_obs;
  end
  methods
    function define_testcases(this)
      % testcase 1
      this.testcases{1}.pth = 'ImportTestData/obs/ID0043-Laurens-BV_COND.obs';
      this.testcases{1}.import{1} = struct('type', 'scr'   , 'channel', 2);
      this.testcases{1}.import{2} = struct('type', 'marker', 'channel', 1);
      % testcase 2
      this.testcases{2}.pth = 'ImportTestData/obs/ID0043-Laurens-BV_COND.obs';
      this.testcases{2}.import{1} = struct('type', 'scr'   , 'channel', 0);
      this.testcases{2}.import{2} = struct('type', 'marker', 'channel', 0);
    end
  end
  methods (Test)
    function invalid_datafile(this)
      fn = 'ImportTestData/obs/ID0043-Laurens-BV_COND.obs';
      import{1} = struct('type', 'scr'   , 'channel', 2);
      import{2} = struct('type', 'marker', 'channel', 1);
      import{3} = struct('type', 'scr'   , 'channel', 4);
      import = this.assign_channeltype_number(import);
      this.verifyWarning(@()pspm_get_obs(fn, import), 'ID:channel_not_contained_in_file');
    end
  end
end