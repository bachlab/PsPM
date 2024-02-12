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
  end
  methods (TestMethodSetup)
    function define_testcases(this)
      this.fn = 'ImportTestData/smrx/25.10.2023.smrx';
      this.fn2 = 'ImportTestData/smrx/25.10.2023_Versuch2.smrx';
      import_raw{1} = struct('type', 'scr', 'channel', 1,'transfer','none','flank','both','typeno',5);
      this.import = import_raw;
    end
  end
  methods (Test)
    function test_basic(this)
      this.verifyWarningFree(@()pspm_get_smrx(this.fn, this.import));
    end
  end
end
