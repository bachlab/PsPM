classdef pspm_get_labchartmat_ext_test < pspm_get_superclass
  % SCR_GET_LABCHARTMAT_EXT_TEST
  % unittest class for the pspm_get_labchartmat_ext function
  % PsPM TestEnvironment
  % (C) 2013 Linus Rüttimann (University of Zurich)

  properties
    testcases;
    fhandle = @pspm_get_labchartmat_ext;
  end

  methods
    function define_testcases(this)
      % testcase 1
      this.testcases{1}.pth = 'ImportTestData/labchart/LabChartMat_ext_SCR_ECG_HR.mat';
      this.testcases{1}.import{1} = struct('type', 'scr'   , 'channel', 1);
      this.testcases{1}.import{2} = struct('type', 'scr'   , 'channel', 2);
      this.testcases{1}.import{3} = struct('type', 'hr'    , 'channel', 3);
      this.testcases{1}.import{4} = struct('type', 'marker', 'channel', 0);
    end
  end

  methods (Test)
    function invalid_datafile(this)
      fn = 'ImportTestData/labchart/LabChartMat_ext_SCR_ECG_HR.mat';
      import{1} = struct('type', 'scr'   , 'channel', 1);
      import{2} = struct('type', 'scr'   , 'channel', 5);
      import{3} = struct('type', 'marker', 'channel', 0);
      import = this.assign_chantype_number(import);
      this.verifyWarning(@()pspm_get_labchartmat_ext(fn, import), 'ID:channel_not_contained_in_file');
    end
  end
end