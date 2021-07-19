classdef pspm_load_data_test < matlab.unittest.TestCase
    
    % pspm_load_data_test
    % unittest class for the pspm_load_data function
    
    % (C) 2013 Linus Rüttimann (University of Zurich)
    % Reviewed: July 2021 Teddy (WCHN, UCL)
    
    properties(Constant)
        fn1 = 'testdatafile_load_data_1.mat';
        fn2 = 'testdatafile_load_data_2.mat';
    end
    
    properties
        event_channels;
        pspm_channels;
    end
    
    methods (TestClassSetup) % Set up required data
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
            
            if exist(testCase.fn1, 'file')
                delete(testCase.fn1);
            end
            
            pspm_testdata_gen(channels,10,testCase.fn1);
            if ~exist(testCase.fn1, 'file')
                warning('ID:invalid_data_generation', 'the testdata could not be generated');
            end
        end
    end
    
    
    methods (Test) % Testing
        
        % check warnings
        function invalid_inputargs(testCase)
            testCase.verifyWarning(@()pspm_load_data, 'ID:invalid_input', 'invalid_inputargs test 1');
            testCase.verifyWarning(@()pspm_load_data(1), 'ID:invalid_input', 'invalid_inputargs test 2');
            testCase.verifyWarning(@()pspm_load_data('fn1', -1), 'ID:invalid_input', 'invalid_inputargs test 3');
            testCase.verifyWarning(@()pspm_load_data('fn1', 'foobar'), 'ID:invalid_channeltype', 'invalid_inputargs test 4');
            foobar.data = 1;
            testCase.verifyWarning(@()pspm_load_data('fn1', foobar), 'ID:invalid_input', 'invalid_inputargs test 5');
            clear foobar
            testCase.verifyWarning(@()pspm_load_data('fn1', {1}), 'ID:invalid_input', 'invalid_inputargs test 6');
            struct.data = cell(3,1);
            testCase.verifyWarning(@()pspm_load_data(struct), 'ID:invalid_input', 'invalid_inputargs test 7');
            testCase.verifyWarning(@()pspm_load_data(testCase.fn1, 250), 'ID:invalid_input', 'invalid_inputargs test 8');
        end
        
        function invalid_datafile(testCase)
            if exist(testCase.fn2, 'file')
                delete(testCase.fn2);
            end
            testCase.verifyWarning(@()pspm_load_data(testCase.fn2), 'ID:nonexistent_file', 'invalid_datafile test 1');
            
            load(testCase.fn1);
            
            save(testCase.fn2, 'data');
            testCase.verifyWarning(@()pspm_load_data(testCase.fn2), 'ID:invalid_data_structure', 'invalid_datafile test 2');
            
            save(testCase.fn2, 'infos');
            testCase.verifyWarning(@()pspm_load_data(testCase.fn2), 'ID:invalid_data_structure', 'invalid_datafile test 3');
            
            fulldata = data;
            data{2} = rmfield(fulldata{2}, 'data');
            save(testCase.fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(testCase.fn2), 'ID:invalid_data_structure', 'invalid_datafile test 4');
            
            data = fulldata;
            data{3} = rmfield(fulldata{3}, 'header');
            save(testCase.fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(testCase.fn2), 'ID:invalid_data_structure', 'invalid_datafile test 5');
            
            data = fulldata;
            data{7}.header = rmfield(fulldata{7}.header, 'sr');
            save(testCase.fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(testCase.fn2), 'ID:invalid_data_structure', 'invalid_datafile test 6');
            
            data = fulldata;
            data{4}.data = [data{4}.data data{4}.data];
            save(testCase.fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(testCase.fn2), 'ID:invalid_data_structure', 'invalid_datafile test 7');
            
            data = fulldata;
            data{1}.data = [data{1}.data; 1;1;1;1];
            save(testCase.fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(testCase.fn2), 'ID:invalid_data_structure', 'invalid_datafile test 8');
            
            data = fulldata;
            data{2}.data = [data{2}.data; infos.duration+0.1];
            save(testCase.fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(testCase.fn2), 'ID:invalid_data_structure', 'invalid_datafile test 9');
            
            data = fulldata;
            data{5}.header.chantype = 'scanner';
            save(testCase.fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(testCase.fn2), 'ID:invalid_data_structure', 'invalid_datafile test 10');
            
            data = fulldata;
            data{2}.data = [data{2}.data; infos.duration+0.1];
            chan.infos = infos; chan.data = data; chan.options.overwrite = 1;
            testCase.verifyWarning(@()pspm_load_data(testCase.fn2, chan), 'ID:invalid_data_structure', 'invalid_datafile test 11');
            
            clear infos data chan
            delete(testCase.fn2);
        end
        
        %return all channels
        function valid_datafile_0(testCase)
            [~, infos, data] = pspm_load_data(testCase.fn1);
            act_val.infos = infos;
            act_val.data = data;
            exp_val = load(testCase.fn1);
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_0 test 1');
        end
        
        %return all channels when input is a struct
        function valid_datafile_1(testCase)
            struct = load(testCase.fn1);
            [~, infos, data] = pspm_load_data(struct);
            act_val.infos = infos;
            act_val.data = data;
            exp_val = load(testCase.fn1);
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_0 test 1');
        end
        
        %return one channel
        function valid_datafile_2(testCase)
            chan = 2;
            
            [~, infos, data] = pspm_load_data(testCase.fn1, chan);
            act_val.infos = infos;
            act_val.data = data;
            
            exp_val = load(testCase.fn1);
            exp_val.data = exp_val.data(chan);
            
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_1 test 1');
        end
        
        %return multiple channels
        function valid_datafile_3(testCase)
            chan = [3 5];
            
            [~, infos, data] = pspm_load_data(testCase.fn1, chan);
            act_val.infos = infos;
            act_val.data = data;
            
            exp_val = load(testCase.fn1);
            exp_val.data = exp_val.data(chan);
            
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_2 test 1');
        end
        
        %return scr channels
        function valid_datafile_4(testCase)
            chan = 'scr';
            
            [~, infos, data] = pspm_load_data(testCase.fn1, chan);
            act_val.infos = infos;
            act_val.data = data;
            
            exp_val = load(testCase.fn1);
            exp_val.data = exp_val.data(testCase.pspm_channels);
            
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_3 test 1');
        end
        
        %return event channels
        function valid_datafile_5(testCase)
            chan = 'events';
            
            [~, infos, data] = pspm_load_data(testCase.fn1, chan);
            act_val.infos = infos;
            act_val.data = data;
            
            exp_val = load(testCase.fn1);
            exp_val.data = exp_val.data(testCase.event_channels);
            
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_4 test 1');
        end
        
        % save data
        function valid_datafile_6(testCase)
            chan = 0;
            [~, infos, data] = pspm_load_data(testCase.fn1, chan); % load
            save.data = data;
            save.infos = infos;
            save.options.overwrite = 1;
            pspm_load_data(testCase.fn2, save);  % save in different file
            
            [~, infos, data] = pspm_load_data(testCase.fn2, chan);% load again
            act_val.infos = infos;
            act_val.data = data;
            exp_val = load(testCase.fn1);
            
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_5 test 1');
            clear save
        end
        
    end
    
    methods (TestClassTeardown) % Clearance
        function del_testdata_file(testCase)
            if exist(testCase.fn1, 'file')
                delete(testCase.fn1);
            end
            if exist(testCase.fn2, 'file')
                delete(testCase.fn2);
            end
        end
    end
    
end

