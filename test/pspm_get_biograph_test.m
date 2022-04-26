classdef pspm_get_biograph_test < pspm_get_superclass
  % SCR_GET_BIOGRAPH_TEST
  % unittest class for the pspm_get_biograph function
  % SCRalyze TestEnvironment
  % (C) 2013 Linus Rüttimann (University of Zurich)
  properties
    testcases;
    fhandle = @pspm_get_biograph;
  end
  methods
    function define_testcases(this)
      % testcase 1
      this.testcases{1}.pth = 'ImportTestData/biograph/Biograph_SCR.txt';
      this.testcases{1}.import{1} = struct('type', 'scr', 'channel', 1);
      % testcase 2
      this.testcases{2}.pth = 'ImportTestData/biograph/Biograph_HB.txt';
      this.testcases{2}.import{1} = struct('type', 'hb', 'channel', 1);
    end
  end
end