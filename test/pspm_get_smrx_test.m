classdef pspm_get_smrx_test < pspm_get_superclass
  % ● Description
  %   unittest class for the pspm_get_smrx function
  % ● History
  %   Written in 2023 by Teddy
  properties
    testcases;
    fhandle = @pspm_get_smrx;
    datatype = 'smrx';
    fn;
    fn2;
    import;
    import2;
    import3;
  end
  methods (TestMethodSetup)
    function define_testcases(this)
      this.fn = 'ImportTestData/spike/25Oct2023.smrx';
      this.fn2 = 'ImportTestData/spike/25.10.2023_Versuch2.smrx';
      import_raw{1} = struct('type', 'scr', 'channel', 1,'transfer','none','flank','both','typeno',5);
      this.import = import_raw;
      import2_raw = {};
      import2_raw{1}.type = 'scr';
      import2_raw{1}.channel = 1;
      import2_raw{1}.transfer = 'none';
      import2_raw{2}.type = 'custom';
      import2_raw{2}.channel = 4;
      import3_raw = {};
      import3_raw{1}.type = 'marker';
      import3_raw{1}.channel = 5;
      this.import2 = import2_raw;
      this.import3 = import3_raw;
    end
  end
  methods (Test)
    function test_basic(this)
      %this.verifyWarningFree(@()pspm_import(this.fn, 'smrx', this.import));
      this.verifyWarningFree(@()pspm_import(this.fn, 'smrx', this.import2, struct('overwrite', 1)));
      %this.verifyWarningFree(@()pspm_import(this.fn, 'smrx', this.import3, struct('overwrite', 1)));
    end
  end
end
