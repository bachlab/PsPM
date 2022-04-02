classdef pspm_trim_test < matlab.unittest.TestCase

  % Unittest class for the pspm_trim_test function
  % PsPM TestEnvironment
  % (C) 2013 Linus Rüttimann (University of Zurich)
  %     2022 Teddy Chao

  properties(Constant)
    fn = 'trim_test.mat';
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
    function gen_testdata(testCase)
      channels{1}.chantype = 'scr';
      channels{2}.chantype = 'marker';
      channels{3}.chantype = 'hr';
      channels{4}.chantype = 'hb';
      channels{5}.chantype = 'marker';
      channels{6}.chantype = 'resp';
      channels{7}.chantype = 'scr';

      testCase.event_channels = [2 4 5];
      testCase.cont_channels = [1 3 6 7];
      testCase.sr = 100;

      if exist(testCase.fn, 'file')
        delete(testCase.fn);
      end

      pspm_testdata_gen(channels,10,testCase.fn);
      if ~exist(testCase.fn, 'file')
        warning('the testdata could not be generated');
      end
    end
  end

  methods (TestClassTeardown)
    function del_testdata_file(testCase)
      if exist(testCase.fn, 'file')
        delete(testCase.fn);
      end
    end
  end

  methods (Test)
    function invalid_inputargs(testCase)
      testCase.verifyWarning(@()pspm_trim(testCase.fn, [1 2], 5, 'marker'),...
        'ID:invalid_input', 'invalid_inputargs test 1');
      testCase.verifyWarning(@()pspm_trim(testCase.fn, 0, 'bla', 'marker'),...
        'ID:invalid_input', 'invalid_inputargs test 2');
      testCase.verifyWarning(@()pspm_trim(testCase.fn, 0, [], 'marker'),...
        'ID:invalid_input', 'invalid_inputargs test 3');
      testCase.verifyWarning(@()pspm_trim(testCase.fn, 0, 5),...
        'ID:invalid_input', 'invalid_inputargs test 4');
      testCase.verifyWarning(@()pspm_trim(testCase.fn, 0, 5, 6),...
        'ID:invalid_input', 'invalid_inputargs test 5');
      testCase.verifyWarning(@()pspm_trim(testCase.fn, 0, 5, 'bla'),...
        'ID:invalid_input', 'invalid_inputargs test 6');
      testCase.verifyWarning(@()pspm_trim(testCase.fn, 0, 5, [-1 5]),...
        'ID:invalid_input', 'invalid_inputargs test 7');
      testCase.verifyWarning(@()pspm_trim(testCase.fn, 0, 5, [5 4]),...
        'ID:invalid_input', 'invalid_inputargs test 8');
    end

    function marker_tests(testCase)
      for k=1:testCase.numof_markertests
        trimtest(testCase, testCase.fn, 'marker', k, 2);
      end
    end

    function file_tests(testCase)
      for k=1:testCase.numof_filetests
        trimtest(testCase, testCase.fn, 'file', k, 2);
      end
    end

    function num_tests(testCase)
      for k=1:testCase.numof_numtests
        trimtest(testCase, testCase.fn, 'num', k, 2);
      end
    end

    function multiple_files(testCase)
      %with datafile input
      fn2 = 'trim_test_2.mat';
      copyfile(testCase.fn,fn2);
      fncell{1} = testCase.fn;
      fncell{2} = fn2;

      [from, to, exp_val{1}, ~, ~] = filetest_3(testCase);

      newdatafile = pspm_trim(fncell, from, to, 'file');

      import matlab.unittest.constraints.HasElementCount;
      testCase.verifyTrue(iscell(newdatafile),...
        'multiple_files test with datafile input (newdatafile is not a cell array)');

      [~, act_val{1}.infos, act_val{1}.data] = pspm_load_data(newdatafile{1},0);
      [~, act_val{2}.infos, act_val{2}.data] = pspm_load_data(newdatafile{2},0);

      exp_val{1}.infos.trimdate = date;

      exp_val{2} = exp_val{1};
      exp_val{1}.infos.trimfile = newdatafile{1};
      exp_val{2}.infos.trimfile = newdatafile{2};

      import matlab.unittest.constraints.IsEqualTo;
      testCase.verifyThat(act_val, IsEqualTo(exp_val), 'multiple_files test with datafile input');

      delete(newdatafile{1});
      delete(newdatafile{2});
      delete(fn2);


      % with struct input
      [~, datafile{1}.infos, datafile{1}.data] = pspm_load_data(testCase.fn);
      datafile{2} = datafile{1};

      [from, to, exp_val{1}, ~, ~] = filetest_3(testCase);

      newdatafile = pspm_trim(datafile, from, to, 'file');

      import matlab.unittest.constraints.HasElementCount;
      testCase.verifyTrue(iscell(newdatafile), ...
        'multiple_files test with stuct input (newdatafile is not a cell array)');

      act_val = newdatafile;

      exp_val{1}.infos.trimdate = date;

      exp_val{2} = exp_val{1};

      import matlab.unittest.constraints.IsEqualTo;
      testCase.verifyThat(act_val, IsEqualTo(exp_val), 'multiple_files test with stuct input');

    end

    %option tests
    function marker_chan_num_option_test(testCase)
      options.marker_chan_num = 3;
      newdatafile = testCase.verifyWarning(@() ...
        pspm_trim(testCase.fn,'none','none','marker', options), ...
        'ID:invalid_option', 'marker_chan_num_option_test test 1');
      delete(newdatafile);

      struct = load(testCase.fn);
      struct.data{5}.data = struct.data{5}.data(2:end);
      save(testCase.fn,'-struct', 'struct');
      options.marker_chan_num = 5;

      newdatafile = pspm_trim(testCase.fn,'none','none',[2,length(struct.data{2}.data)]);
      [~, exp_val.infos, exp_val.data] = pspm_load_data(newdatafile, 0);
      delete(newdatafile);

      newdatafile = pspm_trim(testCase.fn,'none','none', 'marker', options);
      [~, act_val.infos, act_val.data] = pspm_load_data(newdatafile, 0);
      delete(newdatafile);

      import matlab.unittest.constraints.IsEqualTo;
      testCase.verifyThat(act_val, IsEqualTo(exp_val), 'marker_chan_num_option_test test 2');

    end


  end

  methods
    function trimtest(testCase, datafile, reference, testnum, markerchan)
      switch reference
        case 'marker'
          fhandle = str2func(['markertest_' num2str(testnum)]);
          [from, to, exp_val, warningID, testmsg] = feval(fhandle, testCase, markerchan);
        case 'file'
          fhandle = str2func(['filetest_' num2str(testnum)]);
          [from, to, exp_val, warningID, testmsg] = feval(fhandle, testCase);
        case 'num'
          fhandle = str2func(['numtest_' num2str(testnum)]);
          [from, to, exp_val, warningID, testmsg, num] = feval(fhandle, testCase);
          reference = num;
      end

      if strcmpi(warningID, 'none')
        newdatafile=pspm_trim(datafile, from, to, reference);
      else
        newdatafile = testCase.verifyWarning(@()...
          pspm_trim(datafile, from, to, reference),...
          warningID, [testmsg ' (invalid warning)']);
      end


      [~, act_val.infos, act_val.data] = pspm_load_data(newdatafile,0);

      exp_val.infos.trimdate = date;
      exp_val.infos.trimfile = newdatafile;

      import matlab.unittest.constraints.IsEqualTo;
      testCase.verifyThat(act_val, IsEqualTo(exp_val), testmsg);

      delete(newdatafile);

    end

    %% marker/file/num-testcases
    % REMARK: the properties numof_markertests, numof_filetests and
    %         numof_numtests must be updated if testcases are being
    %         added.

    % reference = 'marker' tests
    function [from, to, exp_val, warningID, testmsg] = markertest_1(testCase, markerchan)
      testmsg = 'markertest 1';
      warningID = 'ID:marker_out_of_range';

      [~, exp_val.infos, exp_val.data] = pspm_load_data(testCase.fn,0);

      from = -20;
      to = 20;

      exp_val.infos.trimpoints = [0 exp_val.infos.duration];
    end

    function [from, to, exp_val, warningID, testmsg] = markertest_2(testCase, markerchan)
      testmsg = 'markertest 2';
      warningID = 'none';

      [~, exp_val.infos, exp_val.data, filestruct] = pspm_load_data(testCase.fn,0);

      from = -1 * exp_val.data{filestruct.posofmarker}.data(1);
      to = exp_val.infos.duration - exp_val.data{filestruct.posofmarker}.data(end);

      exp_val.infos.trimpoints = [0 exp_val.infos.duration];
    end

    function [from, to, exp_val, warningID, testmsg] = markertest_3(testCase, markerchan)
      testmsg = 'markertest 3';
      warningID = 'none';

      [~, exp_val.infos, exp_val.data, filestruct] = pspm_load_data(testCase.fn,0);

      from = 1;
      to = -2;

      nfrom = exp_val.data{filestruct.posofmarker}.data(1)+from;
      nto = exp_val.data{filestruct.posofmarker}.data(end)+to;

      startpoint = ceil(testCase.sr * nfrom)+1;
      endpoint = floor(testCase.sr * nto);

      for k=1:length(testCase.cont_channels)
        exp_val.data{testCase.cont_channels(k)}.data = ...
          exp_val.data{testCase.cont_channels(k)}.data(startpoint:endpoint);
      end

      for k=1:length(testCase.event_channels)
        exp_val.data{testCase.event_channels(k)}.data(exp_val.data{testCase.event_channels(k)}.data > nto) = [];
        exp_val.data{testCase.event_channels(k)}.data = exp_val.data{testCase.event_channels(k)}.data - nfrom;
        exp_val.data{testCase.event_channels(k)}.data(exp_val.data{testCase.event_channels(k)}.data < 0) = [];
      end

      exp_val.infos.trimpoints = [nfrom nto];
      exp_val.infos.duration = nto - nfrom;
    end

    % reference = 'file' tests
    function [from, to, exp_val, warningID, testmsg] = filetest_1(testCase)
      testmsg = 'filetest 1';
      warningID = 'ID:marker_out_of_range';

      [~, exp_val.infos, exp_val.data] = pspm_load_data(testCase.fn,0);

      from = -12.5;
      to = 50;

      exp_val.infos.trimpoints = [0 exp_val.infos.duration];
    end

    function [from, to, exp_val, warningID, testmsg] = filetest_2(testCase)
      testmsg = 'filetest 2';
      warningID = 'none';

      [~, exp_val.infos, exp_val.data] = pspm_load_data(testCase.fn,0);

      from = 0;
      to = exp_val.infos.duration;

      exp_val.infos.trimpoints = [0 exp_val.infos.duration];
    end

    function [from, to, exp_val, warningID, testmsg] = filetest_3(testCase)
      testmsg = 'filetest 3';
      warningID = 'none';

      [~, exp_val.infos, exp_val.data] = pspm_load_data(testCase.fn,0);

      from = 2.1;
      to = exp_val.infos.duration - 2.5;

      startpoint = ceil(testCase.sr * from)+1;
      endpoint = floor(testCase.sr * to);

      for k=1:length(testCase.cont_channels)
        exp_val.data{testCase.cont_channels(k)}.data = ...
          exp_val.data{testCase.cont_channels(k)}.data(startpoint:endpoint);
      end

      for k=1:length(testCase.event_channels)
        exp_val.data{testCase.event_channels(k)}.data(exp_val.data{testCase.event_channels(k)}.data > to) = [];
        exp_val.data{testCase.event_channels(k)}.data = exp_val.data{testCase.event_channels(k)}.data - from;
        exp_val.data{testCase.event_channels(k)}.data(exp_val.data{testCase.event_channels(k)}.data < 0) = [];
      end

      exp_val.infos.trimpoints = [from to];
      exp_val.infos.duration = to - from;
    end

    % reference = [a b] (numeric) tests
    function [from, to, exp_val, warningID, testmsg, num] = numtest_1(testCase)
      testmsg = 'numtest 1';
      warningID = 'ID:marker_out_of_range';

      [~, exp_val.infos, exp_val.data] = pspm_load_data(testCase.fn,0);

      from = -20;
      to = 20;
      num = [2 14];

      exp_val.infos.trimpoints = [0 exp_val.infos.duration];
    end

    function [from, to, exp_val, warningID, testmsg, num] = numtest_2(testCase)
      testmsg = 'numtest 2';
      warningID = 'none';

      [~, exp_val.infos, exp_val.data, filestruct] = pspm_load_data(testCase.fn,0);

      num = [3 8];
      from = -1 * exp_val.data{filestruct.posofmarker}.data(num(1));
      to = exp_val.infos.duration - exp_val.data{filestruct.posofmarker}.data(num(2));

      exp_val.infos.trimpoints = [0 exp_val.infos.duration];
    end

    function [from, to, exp_val, warningID, testmsg, num] = numtest_3(testCase)
      testmsg = 'numtest 3';
      warningID = 'none';

      [~, exp_val.infos, exp_val.data, filestruct] = pspm_load_data(testCase.fn,0);

      num = [2 7];
      from = -1.5;
      to = 2;

      nfrom = exp_val.data{filestruct.posofmarker}.data(num(1))+from;
      nto = exp_val.data{filestruct.posofmarker}.data(num(2))+to;

      startpoint = ceil(testCase.sr * nfrom)+1;
      endpoint = floor(testCase.sr * nto);

      for k = 1:length(testCase.cont_channels)
        exp_val.data{testCase.cont_channels(k)}.data = ...
          exp_val.data{testCase.cont_channels(k)}.data(startpoint:endpoint);
      end

      for k=1:length(testCase.event_channels)
        exp_val.data{testCase.event_channels(k)}.data(exp_val.data{testCase.event_channels(k)}.data > nto) = [];
        exp_val.data{testCase.event_channels(k)}.data = exp_val.data{testCase.event_channels(k)}.data - nfrom;
        exp_val.data{testCase.event_channels(k)}.data(exp_val.data{testCase.event_channels(k)}.data < 0) = [];
      end

      exp_val.infos.trimpoints = [nfrom nto];
      exp_val.infos.duration = nto - nfrom;
    end

    function [from, to, exp_val, warningID, testmsg, num] = numtest_4(testCase)
      testmsg = 'numtest 4';
      warningID = 'ID:marker_out_of_range';

      [~, exp_val.infos, exp_val.data, filestruct] = pspm_load_data(testCase.fn,0);

      from = 'none';
      to = 0;
      exp_val.infos.trimpoints = [0 exp_val.infos.duration];
      num = [1 (numel(exp_val.data{filestruct.posofmarker}.data) + 1)];
    end

  end

end

