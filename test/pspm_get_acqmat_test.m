classdef pspm_get_acqmat_test < pspm_get_superclass
  % ● Description
  % unittest class for the pspm_get_acqmat function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  properties
    testcases;
    fhandle = @pspm_get_acqmat;
  end
  methods
    function define_testcases(this)
      % testcase 1
      this.testcases{1}.pth = 'ImportTestData/acq/Acq_exported_SCR_Marker.mat';
      this.testcases{1}.import{1} = struct('type', 'scr'   , 'channel', 1);
      this.testcases{1}.import{2} = struct('type', 'marker', 'channel', 2);
      % testcase 2
      this.testcases{2}.pth = 'ImportTestData/acq/subject1_SCR_to_10_painful_shocks.mat';
      this.testcases{2}.import{1} = struct('type', 'scr'   , 'channel', 1);
      this.testcases{2}.import{2} = struct('type', 'marker', 'channel', 2);
    end
  end
  methods (Test)
    function invalid_datafile(this)
      fn = 'ImportTestData/acq/Acq_exported_SCR_Marker.mat';
      import{1} = struct('type', 'scr'   , 'channel', 1);
      import{2} = struct('type', 'marker', 'channel', 2);
      import{3} = struct('type', 'marker', 'channel', 4);
      import = this.assign_channeltype_number(import);
      this.verifyWarning(@()pspm_get_acqmat(fn, import), 'ID:channel_not_contained_in_file');
    end
  end
end