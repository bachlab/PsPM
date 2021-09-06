classdef pspm_bf_data_test < matlab.unittest.TestCase
  
  % Testfunction to test the generic settings of a basis function.
  % The generic settings are:
  % [bf,x] = pspm_bf_data(td)
  
  % PsPM TestEnvironment
  % (C) 2021 Teddy Chao (WCHN, UCL)
  
  properties(Constant)
    fn = 'pspm_bf_data_sample.mat';
    td = 1;
  end
  
  properties
    numof_markertests = 3;
    numof_filetests = 3;
    numof_numtests = 4;
    event_channels;
    cont_channels;
    sr;
  end
  
  methods (TestClassSetup)
    function gen_testdata(testcase)
      % build a sample datafile for testing
      channels{1}.chantype = 'scr';
      channels{2}.chantype = 'marker';
      channels{3}.chantype = 'hr';
      channels{4}.chantype = 'hb';
      channels{5}.chantype = 'marker';
      channels{6}.chantype = 'resp';
      channels{7}.chantype = 'scr';
      testcase.event_channels = [2 4 5];
      testcase.cont_channels = [1 3 6 7];
      testcase.sr = 100;
      if exist(testcase.fn, 'file')
        delete(testcase.fn);
      end
      pspm_testdata_gen(channels,10,testcase.fn);
      if ~exist(testcase.fn, 'file')
        warning('the testdata could not be generated');
      end
    end
  end
  
  methods (Test)
    function test_basic(testcase)
      testcase.verifyWarningFree(@()pspm_bf_data(testcase.td));
      % [~, ~] = pspm_bf_data(td);
      if exist(testcase.fn, 'file')
        delete(testcase.fn);
      end
    end
  end
  
end