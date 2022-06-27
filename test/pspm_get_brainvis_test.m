classdef pspm_get_brainvis_test < pspm_get_superclass
  % ● Description
  % unittest class for the pspm_get_brainvis function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  properties
    testcases;
    fhandle = @pspm_get_brainvis;
  end
  methods
    function define_testcases(this)
      %testcase 1
      this.testcases{1}.pth = 'ImportTestData/brainvis/ECue16_SCR.eeg';
      this.testcases{1}.import{1} = struct('type', 'scr'   , 'chan', 1);
      %testcase 2
      this.testcases{2}.pth = 'ImportTestData/brainvis/ECue32_SCR.eeg';
      this.testcases{2}.import{1} = struct('type', 'scr'   , 'chan', 1);
      this.testcases{2}.import{2} = struct('type', 'marker', 'chan', 2);
    end
  end
  methods (Test)
    function invalid_datafile(this)
      fn = 'ImportTestData/brainvis/ECue16_SCR.eeg';
      import{1} = struct('type', 'scr'   , 'chan', 5);
      import = this.assign_chantype_number(import);
      this.verifyWarning(@()pspm_get_brainvis(fn, import), 'ID:channel_not_contained_in_file');
    end
  end
end