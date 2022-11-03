classdef pspm_sf_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_sf
  % ● Authorship
  % (C) 2022 Teddy Chao (UCL)
  properties(Constant)
    fn = 'sf_test.mat';
  end
  properties
    modelfiles = {};
    defaults;
  end
  methods(TestClassSetup)
    %% generate test data
    % these operations are from pspm_load1_test
    function generate_testdata(this)
      % obtain presettings
      global settings;
      if isempty(settings), pspm_init; end
      this.defaults = settings;
      % generate aquisition data
      c{1}.channeltype = 'scr';
      c{2}.channeltype = 'hb';
      pspm_testdata_gen(c, 100, this.fn);
      delete c
      % generate model data
      model.datafile = this.fn;
      model.timeunits = 'seconds';
      mbn = 'model_sf';
      model.timing{1} = [10,20; 23,38; 40,70;];
      model.condition{1}.name = {'a';'b'};
      model.condition{1}.index = [1;2];
      model.modelfile = mbn;
      this.modelfiles{1} = mbn;
      fh = str2func('pspm_sf');
      fh(model);
    end
  end
  methods(TestClassTeardown)
    function remove_testdata(this)
      % Remove Testdata
    end
  end
  methods
    function basic_function_test(this, f, sts, mdltype)
      %...
    end
  end
  methods(Test)
    function invalid_inputargs(this)
      %...
    end
    function invalid_model_structure_general(this)
      %...
    end
    function invalid_model_structure_specific(this)
      %...
    end
    function test_action_none(this)
      %...
    end
    function test_action_stats(this)
      %...
    end
    function test_action_cond(this)
      %...
    end
    function test_action_recon(this)
      %...
    end
    % run before con in order to create a con field
    function test_action_savecon(this)
      %...
    end
    function test_action_con(this)
      %...
    end
    function test_action_all(this)
      %...
    end
    function test_action_save(this)
      %...
    end
    function test_options(this)
      %...
    end
  end
end
