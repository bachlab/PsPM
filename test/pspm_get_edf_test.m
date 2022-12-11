classdef pspm_get_edf_test < pspm_get_superclass
  % ● Description
  % unittest class for the pspm_get_edf function
  % PsPM 3.0 TestEnvironment
  % ● Authorship
  % (C) 2014 Tobias Moser (University of Zurich)
  properties
    testcases;
    fhandle = @pspm_get_edf
  end
  methods
    function define_testcases(this)
      % only testcase at the moment since this is the only kind of
      % data we are able to produce
      % testcase 1
      this.testcases{1}.pth = 'ImportTestData/edf/TM012face.EDF';
      % properties fo file
      % 1-5 EMG data
      % 6-8 noise
      % 10 ecg
      % 9, 13 events (done with automarker setting)
      % 12 scr
      this.testcases{1}.import{1} = struct('type', 'emg', 'channel', 1);
      this.testcases{1}.import{2} = struct('type', 'emg', 'channel', 2);
      this.testcases{1}.import{3} = struct('type', 'emg', 'channel', 3);
      this.testcases{1}.import{4} = struct('type', 'emg', 'channel', 4);
      this.testcases{1}.import{5} = struct('type', 'emg', 'channel', 5);
      this.testcases{1}.import{6} = struct('type', 'ecg', 'channel', 10);
      this.testcases{1}.import{7} = struct('type', 'scr', 'channel', 12);
    end
  end
  methods (Test)
    function invalid_input(this)
      fn = 'ImportTestData/edf/TM012face.EDF';
      import{1} = struct('type', 'scr', 'channel', 100);
      import = this.assign_channeltype_number(import);
      this.verifyWarning(@()pspm_get_edf(fn, import), 'ID:channel_not_contained_in_file');
    end
  end
end