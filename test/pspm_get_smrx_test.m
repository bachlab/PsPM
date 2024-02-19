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
    import1;
    import2;
    import3;
    import4;
  end
  methods (TestMethodSetup)
    function define_testcases(this)
      this.fn = 'ImportTestData/spike/20.12.23_10sec.smrx';
      this.fn2 = 'ImportTestData/spike/25Oct2023.smrx';
      
      import1_raw             = {};
      import1_raw{1}.channel  = 1;
      import1_raw{1}.flank    = 'both';
      import1_raw{1}.transfer = 'none';
      import1_raw{1}.type     = 'scr';
      import1_raw{1}.typeno   = 5;
      this.import1            = import1_raw;
      
      import2_raw             = {};
      import2_raw{1}.channel  = 1;
      import2_raw{1}.transfer = 'none';
      import2_raw{1}.type     = 'scr';
      import2_raw{2}.channel  = 4;
      import2_raw{2}.type     = 'custom';
      this.import2            = import2_raw;
      
      import3_raw             = {};
      import3_raw{1}.channel  = 5;
      import3_raw{1}.type     = 'marker';
      this.import3            = import3_raw;

      import4_raw             = {};
      import4_raw{1}.channel  = 1;
      import4_raw{1}.type     = 'scr';
      import4_raw{1}.channel  = 2;
      import4_raw{1}.type     = 'scr';
      import4_raw{1}.channel  = 5;
      import4_raw{1}.type     = 'marker';
      this.import4            = import4_raw;
    end
  end
  methods (Test)
    function test_basic(this)
      % this.verifyWarningFree(@()pspm_import(this.fn, 'smrx', this.import1));
      % this.verifyWarningFree(@()pspm_import(this.fn, 'smrx', this.import2, struct('overwrite', 1)));
      % this.verifyWarning(@()pspm_import(this.fn, 'smrx', this.import3, struct('overwrite', 1)), 'MATLAB:structOnObject');
      this.verifyWarning(@()pspm_import(this.fn2, 'smrx', this.import4, struct('overwrite', 1)), 'MATLAB:structOnObject');
    end
  end
end
