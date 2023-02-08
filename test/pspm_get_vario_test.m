classdef pspm_get_vario_test < pspm_get_superclass
  % ● Description
  % unittest class for the pspm_get_vario function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  properties
    testcases;
    fhandle = @pspm_get_vario;
  end
  methods
    function define_testcases(this)
      % testcase 1
      this.testcases{1}.pth = 'ImportTestData/vario/Varioport_various_channels.vpd';
      this.testcases{1}.import{1} = struct('type', 'ecg'   , 'channel', 1);
      this.testcases{1}.import{2} = struct('type', 'scr'   , 'channel', 2);
      this.testcases{1}.import{3} = struct('type', 'scr'   , 'channel', 6);
      this.testcases{1}.import{4} = struct('type', 'marker', 'channel', 8);
    end
  end
  methods (Test)
    function invalid_datafile(this)
      fn = 'ImportTestData/vario/Varioport_various_channels.vpd';
      import{1} = struct('type', 'scr'   , 'channel', 1);
      import{2} = struct('type', 'scr'   , 'channel', 12);
      import = this.assign_channeltype_number(import);
      this.verifyWarning(@()pspm_get_vario(fn, import), 'ID:channel_not_contained_in_file');
    end
  end
end