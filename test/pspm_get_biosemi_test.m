classdef pspm_get_biosemi_test < pspm_get_superclass
  % ● Description
  % unittest class for the pspm_get_biosemi function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  properties
    testcases;
    fhandle = @pspm_get_biosemi;
  end
  methods
    function define_testcases(this)
      % testcase 1
      this.testcases{1}.pth = 'ImportTestData/biosemi/91316#00_hab.bdf';
      this.testcases{1}.import{1} = struct('type', 'scr'   , 'chan', 5);
      this.testcases{1}.import{2} = struct('type', 'scr'   , 'chan', 6);
      this.testcases{1}.import{3} = struct('type', 'resp'  , 'chan', 8);
      this.testcases{1}.import{4} = struct('type', 'marker', 'chan', 0);
      % testcase 2
      this.testcases{2}.pth = 'ImportTestData/biosemi/91316#00_hab.bdf';
      this.testcases{2}.import{1} = struct('type', 'scr'   , 'chan', 5);
      this.testcases{2}.import{2} = struct('type', 'scr'   , 'chan', 6);
      this.testcases{2}.import{3} = struct('type', 'resp'  , 'chan', 0);
      this.testcases{2}.import{4} = struct('type', 'marker', 'chan', 0);
    end
  end
  methods (Test)
    function invalid_datafile(this)
      fn = 'ImportTestData/biosemi/91316#00_hab.bdf';
      import{1} = struct('type', 'scr'   , 'chan', 5);
      import{2} = struct('type', 'scr'   , 'chan', 8);
      import{3} = struct('type', 'scr'   , 'chan',12);
      import = this.assign_chantype_number(import);
      this.verifyWarning(@()pspm_get_biosemi(fn, import), 'ID:channel_not_contained_in_file');
    end
  end
end