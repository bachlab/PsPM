classdef pspm_get_mat_test < pspm_get_superclass
  % ● Description
  % unittest class for the pspm_get_mat function
  % PsPM TestEnvironment
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  properties
    testcases;
    fhandle = @pspm_get_mat;
    datatype = 'mat';
  end
  methods
    function define_testcases(this)
      % testcase 1 (cell structure)
      this.testcases{1}.pth = 'testfile_get_mat_test_1.mat';
      this.testcases{1}.datasubtype = 1; % cell structure
      this.testcases{1}.import{1} = struct('type', 'scr'   , 'chan', 1, 'sr', 100);
      this.testcases{1}.import{2} = struct('type', 'marker', 'chan', 2, 'sr',   1);
      this.testcases{1}.import{3} = struct('type', 'hr'    , 'chan', 5, 'sr', 100);
      this.testcases{1}.import{4} = struct('type', 'hb'    , 'chan', 4, 'sr',   1);
      this.testcases{1}.import{5} = struct('type', 'marker', 'chan', 3, 'sr',   1);
      this.testcases{1}.import{6} = struct('type', 'resp'  , 'chan', 6, 'sr', 100);
      this.testcases{1}.import{7} = struct('type', 'scr'   , 'chan', 7, 'sr', 100);
      % generate testdata
      chans1{1}.chantype = 'scr';
      chans1{2}.chantype = 'marker';
      chans1{3}.chantype = 'marker';
      chans1{4}.chantype = 'hb';
      chans1{5}.chantype = 'hr';
      chans1{6}.chantype = 'resp';
      chans1{7}.chantype = 'scr';
      gendata = pspm_testdata_gen(chans1);
      for k = 1:numel(this.testcases{1}.import)
        data{k} = gendata.data{k}.data;
      end
      save(this.testcases{1}.pth, 'data');
      % testcase 2 (matrix structure)
      this.testcases{2}.pth = 'testfile_get_mat_test_2.mat';
      this.testcases{2}.datasubtype = 2; % matrix structure
      this.testcases{2}.import{1} = struct('type', 'scr'   , 'chan', 1, 'sr', 100);
      this.testcases{2}.import{2} = struct('type', 'scr'   , 'chan', 4, 'sr', 200);
      this.testcases{2}.import{3} = struct('type', 'hr'    , 'chan', 3, 'sr', 100);
      this.testcases{2}.import{4} = struct('type', 'scr'   , 'chan', 2, 'sr', 100);
      % generate testdata
      chans2{1}.chantype = 'scr';
      chans2{2}.chantype = 'scr';
      chans2{3}.chantype = 'hr';
      chans2{4}.chantype = 'scr';
      gendata = pspm_testdata_gen(chans2);
      data = [];
      for k = 1:numel(this.testcases{2}.import)
        data = [data, gendata.data{k}.data];
      end
      save(this.testcases{2}.pth, 'data');
    end
  end
  methods (TestClassTeardown)
    function del_testdata_files(this)
      delete(this.testcases{1}.pth);
      delete(this.testcases{2}.pth);
      this.testcases = [];
    end
  end
  methods (Test)
    function invalid_datafile(this)
      fn = 'testfile_get_mat_test_3.mat';
      a = 3;
      save(fn, 'a');
      this.verifyWarning(@()pspm_get_mat(fn, this.testcases{1}.import), ...
      'ID:invalid_data_structure', 'invalid_datafile test 1');
      data = 'string';
      save(fn, 'data');
      this.verifyWarning(@()pspm_get_mat(fn, this.testcases{1}.import), ...
      'ID:invalid_data_structure', 'invalid_datafile test 2');
      data = cell(2,1);
      data{1} = ones(50,1);
      data{2} = ones(50,2);
      save(fn, 'data');
      this.verifyWarning(@()pspm_get_mat(fn, this.testcases{1}.import), ...
      'ID:invalid_data_structure', 'invalid_datafile test 3');
      delete(fn);
      fn = this.testcases{2}.pth;
      import{1} = struct('type', 'scr'   , 'chan', 1);
      import{2} = struct('type', 'marker', 'chan', 6);
      import = this.assign_chantype_number(import);
      this.verifyWarning(@()pspm_get_mat(fn, import), 'ID:channel_not_contained_in_file');
    end
  end
end