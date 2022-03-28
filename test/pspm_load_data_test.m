classdef pspm_load_data_test < matlab.unittest.TestCase
  % pspm_load_data_test
  % unittest class for the pspm_load_data function
  %__________________________________________________________________________
  % SCRalyze TestEnvironment
  % (C) 2013 Linus Rüttimann (University of Zurich)

  properties(Constant)
    fn = 'load_data_test.mat';
    fn2 = 'load_data_test2.mat';
  end

  properties
    event_channels;
    pspm_channels;
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
      testCase.pspm_channels = [1 7];

      if exist(pspm_load_data_test.fn, 'file')
        delete(pspm_load_data_test.fn);
      end

      pspm_testdata_gen(channels, 10, pspm_load_data_test.fn);

      if ~exist(pspm_load_data_test.fn, 'file')
        warning('the testdata could not be generated');
      end
    end
  end

  methods (TestClassTeardown)
    function del_testdata_file(testCase)
      if exist(pspm_load_data_test.fn, 'file')
        delete(pspm_load_data_test.fn);
      end
    end
  end

  methods (Test)

    % Test group 1: check warnings
    function invalid_inputargs(testCase)
      % test 1
      testCase.verifyWarning(@()pspm_load_data(), ...
        'ID:invalid_input', ...
        'invalid_inputargs test 1');
      % test 2
      testCase.verifyWarning(@()pspm_load_data(1), ...
        'ID:invalid_input', ...
        'invalid_inputargs test 2');
      % test 3
      testCase.verifyWarning(@()pspm_load_data('fn', -1), ...
        'ID:nonexistent_file', ...
        'invalid_inputargs test 3');
      % test 4
      testCase.verifyWarning(@()pspm_load_data(pspm_load_data_test.fn, 'foobar'), ...
        'ID:invalid_channeltype', ...
        'invalid_inputargs test 4');
      % test 5
      foobar.data = 1;
      testCase.verifyWarning(@()pspm_load_data(pspm_load_data_test.fn, foobar), ...
        'ID:invalid_input', ...
        'invalid_inputargs test 5');
      clear foobar
      % test 6
      testCase.verifyWarning(@()pspm_load_data(pspm_load_data_test.fn, {1}), ...
        'ID:invalid_input', ...
        'invalid_inputargs test 6');
      % test 7
      struct.data = cell(3,1);
      testCase.verifyWarning(@()pspm_load_data(struct), ...
        'ID:invalid_input', ...
        'invalid_inputargs test 7');
      % test 8
      testCase.verifyWarning(@()pspm_load_data(pspm_load_data_test.fn, 250), ...
        'ID:invalid_input', ...
        'invalid_inputargs test 8');
    end

    function invalid_datafile(testCase)
      if exist(testCase.fn2, 'file')
        delete(testCase.fn2);
      end
      % invalid_datafile test 1
      testCase.verifyWarning(@()pspm_load_data(testCase.fn2), ...
        'ID:nonexistent_file', ...
        'invalid_datafile test 1');
      % invalid_datafile test 2
      load(pspm_load_data_test.fn, 'data');
      save(testCase.fn2, 'data');
      clear('data')
      testCase.verifyWarning(@()pspm_load_data(testCase.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 2');
      % invalid_datafile test 3
      load(pspm_load_data_test.fn, 'infos');
      save(testCase.fn2, 'infos');
      clear('infos')
      testCase.verifyWarning(@()pspm_load_data(testCase.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 3');
      % invalid_datafile test 4
      load(pspm_load_data_test.fn, 'infos');
      load(pspm_load_data_test.fn, 'data');
      data{2} = rmfield(data{2}, 'data');
      save(testCase.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      testCase.verifyWarning(@()pspm_load_data(testCase.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 4');
      % invalid_datafile test 5
      load(pspm_load_data_test.fn, 'infos');
      load(pspm_load_data_test.fn, 'data');
      data{3} = rmfield(data{3}, 'header');
      save(testCase.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      testCase.verifyWarning(@()pspm_load_data(testCase.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 5');
      % invalid_datafile test 6
      load(pspm_load_data_test.fn, 'infos');
      load(pspm_load_data_test.fn, 'data');
      data{7}.header = rmfield(data{7}.header, 'sr');
      save(testCase.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      testCase.verifyWarning(@()pspm_load_data(testCase.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 6');
      % invalid_datafile test 7
      load(pspm_load_data_test.fn, 'infos');
      load(pspm_load_data_test.fn, 'data');
      data{4}.data = [data{4}.data data{4}.data];
      save(testCase.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      testCase.verifyWarning(@()pspm_load_data(testCase.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 7');
      % invalid_datafile test 8
      load(pspm_load_data_test.fn, 'infos');
      load(pspm_load_data_test.fn, 'data');
      data{1}.data = [data{1}.data; 1;1;1;1];
      save(testCase.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      testCase.verifyWarning(@()pspm_load_data(testCase.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 8');
      % invalid_datafile test 9
      load(pspm_load_data_test.fn, 'infos');
      load(pspm_load_data_test.fn, 'data');
      data{2}.data = [data{2}.data; infos.duration+0.1];
      save(testCase.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      testCase.verifyWarning(@()pspm_load_data(testCase.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 9');
      % invalid_datafile test 10
      load(pspm_load_data_test.fn, 'infos');
      load(pspm_load_data_test.fn, 'data');
      data{5}.header.chantype = 'scanner';
      save(testCase.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      testCase.verifyWarning(@()pspm_load_data(testCase.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 10');
      % invalid_datafile test 11
      load(pspm_load_data_test.fn, 'infos');
      load(pspm_load_data_test.fn, 'data');
      data{2}.data = [data{2}.data; infos.duration+0.1];
      save(testCase.fn2, 'infos', 'data');
      chan.infos = infos;
      chan.data = data;
      chan.options.overwrite = 1;
      clear('infos')
      clear('data')
      testCase.verifyWarning(@()pspm_load_data(testCase.fn2, chan), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 11');
      % end invalid_datafile tests
      clear infos data chan
      delete(testCase.fn2);
    end

    %return all channels
    function valid_datafile_0(testCase)
      [~, infos, data] = pspm_load_data(pspm_load_data_test.fn);
      act_val.infos = infos;
      act_val.data = data;
      exp_val = load(pspm_load_data_test.fn);
      import matlab.unittest.constraints.IsEqualTo;
      testCase.verifyThat(act_val.data{1,1}.header.chantype,...
        IsEqualTo(exp_val.data{1,1}.header.chantype), 'valid_datafile_0 test 1');
      testCase.verifyThat(act_val.data{1,1}.header.sr,...
        IsEqualTo(exp_val.data{1,1}.header.sr), 'valid_datafile_0 test 1');
      testCase.verifyThat(act_val.data{1,1}.header.freq,...
        IsEqualTo(exp_val.data{1,1}.header.freq), 'valid_datafile_0 test 1');
      testCase.verifyThat(act_val.data{1,1}.header.noise,...
        IsEqualTo(exp_val.data{1,1}.header.noise), 'valid_datafile_0 test 1');
      testCase.verifyThat(act_val.data{1,1}.header.units,...
        IsEqualTo(exp_val.data{1,1}.header.units), 'valid_datafile_0 test 1');
      testCase.verifyThat(act_val.infos, IsEqualTo(exp_val.infos), 'valid_datafile_0 test 1');
    end

    % return all channels when input is a struct
    function valid_datafile_1(testCase)
      struct = load(pspm_load_data_test.fn);
      [~, infos, data] = pspm_load_data(struct);
      act_val.infos = infos;
      act_val.data = data;
      exp_val = load(pspm_load_data_test.fn);
      import matlab.unittest.constraints.IsEqualTo;
      testCase.verifyThat(act_val.data{1,1}.header.chantype,...
        IsEqualTo(exp_val.data{1,1}.header.chantype), 'valid_datafile_0 test 1');
      testCase.verifyThat(act_val.data{1,1}.header.sr,...
        IsEqualTo(exp_val.data{1,1}.header.sr), 'valid_datafile_0 test 1');
      testCase.verifyThat(act_val.data{1,1}.header.freq,...
        IsEqualTo(exp_val.data{1,1}.header.freq), 'valid_datafile_0 test 1');
      testCase.verifyThat(act_val.data{1,1}.header.noise,...
        IsEqualTo(exp_val.data{1,1}.header.noise), 'valid_datafile_0 test 1');
      testCase.verifyThat(act_val.data{1,1}.header.units,...
        IsEqualTo(exp_val.data{1,1}.header.units), 'valid_datafile_0 test 1');
      testCase.verifyThat(act_val.infos, IsEqualTo(exp_val.infos), 'valid_datafile_0 test 1');
    end

    %return one channel
    function valid_datafile_2(testCase)
      chan = 2;

      [~, infos, data] = pspm_load_data(pspm_load_data_test.fn, chan);
      act_val.infos = infos;
      act_val.data = data;

      exp_val = load(pspm_load_data_test.fn);
      exp_val.data = exp_val.data(chan);

      import matlab.unittest.constraints.IsEqualTo;
%       testCase.verifyThat(act_val.data{1,1}.header.chantype,...
%         IsEqualTo(exp_val.data{1,1}.header.chantype), 'valid_datafile_1 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.sr,...
%         IsEqualTo(exp_val.data{1,1}.header.sr), 'valid_datafile_1 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.freq,...
%         IsEqualTo(exp_val.data{1,1}.header.freq), 'valid_datafile_1 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.noise,...
%         IsEqualTo(exp_val.data{1,1}.header.noise), 'valid_datafile_1 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.units,...
%         IsEqualTo(exp_val.data{1,1}.header.units), 'valid_datafile_1 test 1');
      testCase.verifyThat(act_val.infos, IsEqualTo(exp_val.infos), 'valid_datafile_1 test 1');
    end

    %return multiple channels
    function valid_datafile_3(testCase)
      chan = [3 5];

      [~, infos, data] = pspm_load_data(pspm_load_data_test.fn, chan);
      act_val.infos = infos;
      act_val.data = data;

      exp_val = load(pspm_load_data_test.fn);
      exp_val.data = exp_val.data(chan);

      import matlab.unittest.constraints.IsEqualTo;
%       testCase.verifyThat(act_val.data{1,1}.header.chantype,...
%         IsEqualTo(exp_val.data{1,1}.header.chantype), 'valid_datafile_2 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.sr,...
%         IsEqualTo(exp_val.data{1,1}.header.sr), 'valid_datafile_2 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.freq,...
%         IsEqualTo(exp_val.data{1,1}.header.freq), 'valid_datafile_2 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.noise,...
%         IsEqualTo(exp_val.data{1,1}.header.noise), 'valid_datafile_2 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.units,...
%         IsEqualTo(exp_val.data{1,1}.header.units), 'valid_datafile_2 test 1');
      testCase.verifyThat(act_val.infos, IsEqualTo(exp_val.infos), 'valid_datafile_2 test 1');
    end

    %return scr channels
    function valid_datafile_4(testCase)
      chan = 'scr';

      [~, infos, data] = pspm_load_data(pspm_load_data_test.fn, chan);
      act_val.infos = infos;
      act_val.data = data;

      exp_val = load(pspm_load_data_test.fn);
      exp_val.data = exp_val.data(testCase.pspm_channels);

      import matlab.unittest.constraints.IsEqualTo;
%       testCase.verifyThat(act_val.data{1,1}.header.chantype,...
%         IsEqualTo(exp_val.data{1,1}.header.chantype), 'valid_datafile_3 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.sr,...
%         IsEqualTo(exp_val.data{1,1}.header.sr), 'valid_datafile_3 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.freq,...
%         IsEqualTo(exp_val.data{1,1}.header.freq), 'valid_datafile_3 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.noise,...
%         IsEqualTo(exp_val.data{1,1}.header.noise), 'valid_datafile_3 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.units,...
%         IsEqualTo(exp_val.data{1,1}.header.units), 'valid_datafile_3 test 1');
      testCase.verifyThat(act_val.infos, IsEqualTo(exp_val.infos), 'valid_datafile_3 test 1');
    end

    %return event channels
    function valid_datafile_5(testCase)
      chan = 'events';

      [~, infos, data] = pspm_load_data(pspm_load_data_test.fn, chan);
      act_val.infos = infos;
      act_val.data = data;

      exp_val = load(pspm_load_data_test.fn);
      exp_val.data = exp_val.data(testCase.event_channels);

      import matlab.unittest.constraints.IsEqualTo;
%       testCase.verifyThat(act_val.data{1,1}.header.chantype,...
%         IsEqualTo(exp_val.data{1,1}.header.chantype), 'valid_datafile_4 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.sr,...
%         IsEqualTo(exp_val.data{1,1}.header.sr), 'valid_datafile_4 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.freq,...
%         IsEqualTo(exp_val.data{1,1}.header.freq), 'valid_datafile_4 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.noise,...
%         IsEqualTo(exp_val.data{1,1}.header.noise), 'valid_datafile_4 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.units,...
%         IsEqualTo(exp_val.data{1,1}.header.units), 'valid_datafile_4 test 1');
      testCase.verifyThat(act_val.infos, IsEqualTo(exp_val.infos), 'valid_datafile_4 test 1');
    end

    % save data
    function valid_datafile_6(testCase)
      chan = 0;
      [~, infos, data] = pspm_load_data(pspm_load_data_test.fn, chan); % load
      save.data = data;
      save.infos = infos;
      save.options.overwrite = 1;
      pspm_load_data(testCase.fn, save);                                 % save in different file

      [~, infos, data] = pspm_load_data(testCase.fn, chan);% load again
      act_val.infos = infos;
      act_val.data = data;
      exp_val = load(pspm_load_data_test.fn);

      import matlab.unittest.constraints.IsEqualTo;
%       testCase.verifyThat(act_val.data{1,1}.header.chantype,...
%         IsEqualTo(exp_val.data{1,1}.header.chantype), 'valid_datafile_5 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.sr,...
%         IsEqualTo(exp_val.data{1,1}.header.sr), 'valid_datafile_5 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.freq,...
%         IsEqualTo(exp_val.data{1,1}.header.freq), 'valid_datafile_5 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.noise,...
%         IsEqualTo(exp_val.data{1,1}.header.noise), 'valid_datafile_5 test 1');
%       testCase.verifyThat(act_val.data{1,1}.header.units,...
%         IsEqualTo(exp_val.data{1,1}.header.units), 'valid_datafile_5 test 1');
      testCase.verifyThat(act_val.infos, IsEqualTo(exp_val.infos), 'valid_datafile_5 test 1');
      delete(testCase.fn);
      clear save
    end


  end


end

