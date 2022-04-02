classdef pspm_load_data_test < matlab.unittest.TestCase
  
	% pspm_load_data_test
  % unittest class for the pspm_load_data function
  % testEnvironment for PsPM version 6.0
  % (C) 2013 Linus Rüttimann (University of Zurich)
  %     2022 Teddy Chao (UCL)

  properties(Constant)
    fn = 'load_data_test.mat';
    fn2 = 'load_data_test2.mat';
  end

  properties
    event_channels;
    pspm_channels;
  end

  properties(TestParameter)
  end

  methods
    function compare_data(this, act_val, exp_val)
			% this method is recommened for comparing structs (Infos, data, header)
			% because load_data will autofill some fields which should be allowed as different
      import matlab.unittest.constraints.IsEqualTo;
      % Verify Infos
      ExpStructInfos = exp_val.infos;
      ActStructInfos = act_val.infos;
      this.verifyThat(ExpStructInfos, ...
      								IsEqualTo(ActStructInfos), ...
      								'valid_datafile_0 test 1');
      ExpStruct = exp_val.data;
      ActStruct = act_val.data;
      for i_struct = 1:length(ExpStruct)
        ExpHeader = ExpStruct{i_struct,1}.header;
        ActHeader = ActStruct{i_struct,1}.header;
        ExpData = ExpStruct{i_struct,1}.data;
        ActData = ActStruct{i_struct,1}.data;
        % Verify data
        this.verifyThat(ExpData, ...
        								IsEqualTo(ActData), ...
        								'valid_datafile_0 test 1');
        % Verify header
        l_fieldnames = fieldnames(ExpHeader);
        for i_field = 1:numel(l_fieldnames)
          ExpHeaderVal = ExpHeader.(l_fieldnames{i_field});
          ActHeaderVal = ActHeader.(l_fieldnames{i_field});
          this.verifyThat(ExpHeaderVal, ...
          								IsEqualTo(ActHeaderVal), ...
          								'valid_datafile_0 test 1');
        end
      end
    end
  end

  methods (TestClassSetup)
    function gen_testdata(this)
      channels{1}.chantype = 'scr';
      channels{2}.chantype = 'marker';
      channels{3}.chantype = 'hr';
      channels{4}.chantype = 'hb';
      channels{5}.chantype = 'marker';
      channels{6}.chantype = 'resp';
      channels{7}.chantype = 'scr';
      this.event_channels = [2 4 5];
      this.pspm_channels = [1 7];
      if exist(this.fn, 'file')
        delete(this.fn);
      end
      pspm_testdata_gen(channels, 10, this.fn);
      if ~exist(this.fn, 'file')
        warning('the testdata could not be generated');
      end
    end
  end

  methods (TestClassTeardown)
    function del_testdata_file(this)
      if exist(this.fn, 'file')
        delete(this.fn);
      end
    end
  end

  methods (Test)

    function invalid_inputargs(this)
		% Test group 1: check warnings
      % test 1
      this.verifyWarning(@()pspm_load_data(), ...
        'ID:invalid_input', ...
        'invalid_inputargs test 1');
      % test 2
      this.verifyWarning(@()pspm_load_data(1), ...
        'ID:invalid_input', ...
        'invalid_inputargs test 2');
      % test 3
      this.verifyWarning(@()pspm_load_data('fn', -1), ...
        'ID:nonexistent_file', ...
        'invalid_inputargs test 3');
      % test 4
      this.verifyWarning(@()pspm_load_data(this.fn, 'foobar'), ...
        'ID:invalid_channeltype', ...
        'invalid_inputargs test 4');
      % test 5
      foobar.data = 1;
      this.verifyWarning(@()pspm_load_data(this.fn, foobar), ...
        'ID:invalid_input', ...
        'invalid_inputargs test 5');
      clear foobar
      % test 6
      this.verifyWarning(@()pspm_load_data(this.fn, {1}), ...
        'ID:invalid_input', ...
        'invalid_inputargs test 6');
      % test 7
      struct.data = cell(3,1);
      this.verifyWarning(@()pspm_load_data(struct), ...
        'ID:invalid_input', ...
        'invalid_inputargs test 7');
      % test 8
      this.verifyWarning(@()pspm_load_data(this.fn, 250), ...
        'ID:invalid_input', ...
        'invalid_inputargs test 8');
    end

    function invalid_datafile(this)
      if exist(this.fn2, 'file')
        delete(this.fn2);
      end
      % invalid_datafile test 1
      this.verifyWarning(@()pspm_load_data(this.fn2), ...
        'ID:nonexistent_file', ...
        'invalid_datafile test 1');
      % invalid_datafile test 2
      load(this.fn, 'data');
      save(this.fn2, 'data');
      clear('data')
      this.verifyWarning(@()pspm_load_data(this.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 2');
      % invalid_datafile test 3
      load(this.fn, 'infos');
      save(this.fn2, 'infos');
      clear('infos')
      this.verifyWarning(@()pspm_load_data(this.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 3');
      % invalid_datafile test 4
      load(this.fn, 'infos');
      load(this.fn, 'data');
      data{2} = rmfield(data{2}, 'data');
      save(this.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      this.verifyWarning(@()pspm_load_data(this.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 4');
      % invalid_datafile test 5
      load(this.fn, 'infos');
      load(this.fn, 'data');
      data{3} = rmfield(data{3}, 'header');
      save(this.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      this.verifyWarning(@()pspm_load_data(this.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 5');
      % invalid_datafile test 6
      load(this.fn, 'infos');
      load(this.fn, 'data');
      data{7}.header = rmfield(data{7}.header, 'sr');
      save(this.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      this.verifyWarning(@()pspm_load_data(this.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 6');
      % invalid_datafile test 7
      load(this.fn, 'infos');
      load(this.fn, 'data');
      data{4}.data = [data{4}.data data{4}.data];
      save(this.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      this.verifyWarning(@()pspm_load_data(this.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 7');
      % invalid_datafile test 8
      load(this.fn, 'infos');
      load(this.fn, 'data');
      data{1}.data = [data{1}.data; 1;1;1;1];
      save(this.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      this.verifyWarning(@()pspm_load_data(this.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 8');
      % invalid_datafile test 9
      load(this.fn, 'infos');
      load(this.fn, 'data');
      data{2}.data = [data{2}.data; infos.duration+0.1];
      save(this.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      this.verifyWarning(@()pspm_load_data(this.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 9');
      % invalid_datafile test 10
      load(this.fn, 'infos');
      load(this.fn, 'data');
      data{5}.header.chantype = 'scanner';
      save(this.fn2, 'infos', 'data');
      clear('infos')
      clear('data')
      this.verifyWarning(@()pspm_load_data(this.fn2), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 10');
      % invalid_datafile test 11
      load(this.fn, 'infos');
      load(this.fn, 'data');
      data{2}.data = [data{2}.data; infos.duration+0.1];
      save(this.fn2, 'infos', 'data');
      chan.infos = infos;
      chan.data = data;
      chan.options.overwrite = 1;
      clear('infos')
      clear('data')
      this.verifyWarning(@()pspm_load_data(this.fn2, chan), ...
        'ID:invalid_data_structure', ...
        'invalid_datafile test 11');
      % end invalid_datafile tests
      clear infos data chan
      delete(this.fn2);
    end
    
    function valid_datafile_0(this) % return all channels
      [~, infos, data] = pspm_load_data(this.fn);
      act_val.infos = infos;
      act_val.data = data;
      exp_val = load(this.fn);
      this.compare_data(act_val, exp_val);
    end

    function valid_datafile_1(this) % return all channels when input is a struct
      struct = load(this.fn);
      [~, infos, data] = pspm_load_data(struct);
      act_val.infos = infos;
      act_val.data = data;
      exp_val = load(this.fn);
      this.compare_data(act_val, exp_val);
    end
    
    function valid_datafile_2(this) % return one channel
      chan = 2;
      [~, infos, data] = pspm_load_data(this.fn, chan);
      act_val.infos = infos;
      act_val.data = data;
      exp_val = load(this.fn);
      exp_val.data = exp_val.data(chan);
      this.compare_data(act_val, exp_val);
    end
    
    function valid_datafile_3(this) % return multiple channels
      chan = [3 5];
      [~, infos, data] = pspm_load_data(this.fn, chan);
      act_val.infos = infos;
      act_val.data = data;
      exp_val = load(this.fn);
      exp_val.data = exp_val.data(chan);
      this.compare_data(act_val, exp_val);
    end

    function valid_datafile_4(this) % return scr channels
      chan = 'scr';
      [~, infos, data] = pspm_load_data(this.fn, chan);
      act_val.infos = infos;
      act_val.data = data;
      exp_val = load(this.fn);
      exp_val.data = exp_val.data(this.pspm_channels);
      this.compare_data(act_val, exp_val);
    end

    function valid_datafile_5(this) % return event channels
      chan = 'events';
      [~, infos, data] = pspm_load_data(this.fn, chan);
      act_val.infos = infos;
      act_val.data = data;
      exp_val = load(this.fn);
      exp_val.data = exp_val.data(this.event_channels);
      this.compare_data(act_val, exp_val);
    end

    function valid_datafile_6(this) % save data
      chan = 0;
      [~, infos, data] = pspm_load_data(this.fn, chan); % load
      save.data = data;
      save.infos = infos;
      save.options.overwrite = 1;
      pspm_load_data(this.fn, save); % save in different file
      [~, infos, data] = pspm_load_data(this.fn, chan);% load again
      act_val.infos = infos;
      act_val.data = data;
      exp_val = load(this.fn);
      this.compare_data(act_val, exp_val);
      delete(this.fn);
      clear save
    end
		
  end
	
end