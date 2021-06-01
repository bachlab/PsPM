classdef pspm_load_data_test < matlab.unittest.TestCase
% SCR_LOAD_DATA_TEST 
% unittest class for the pspm_load_data function
%__________________________________________________________________________
% SCRalyze TestEnvironment
% (C) 2013 Linus R�ttimann (University of Zurich)

% $Id: pspm_load_data_test.m 646 2019-04-25 11:48:57Z esrefo $
    
    properties(Constant)
        fn = 'testdatafile79887.mat';
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
            
            pspm_testdata_gen(channels,10,pspm_load_data_test.fn);
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
        
        %check warnings
        function invalid_inputargs(testCase)
            testCase.verifyWarning(@()pspm_load_data, 'ID:invalid_input', 'invalid_inputargs test 1');
            testCase.verifyWarning(@()pspm_load_data(1), 'ID:invalid_input', 'invalid_inputargs test 2');
            testCase.verifyWarning(@()pspm_load_data('fn', -1), 'ID:invalid_input', 'invalid_inputargs test 3');
            testCase.verifyWarning(@()pspm_load_data('fn', 'foobar'), 'ID:invalid_channeltype', 'invalid_inputargs test 4');
            foobar.data = 1; 
            testCase.verifyWarning(@()pspm_load_data('fn', foobar), 'ID:invalid_input', 'invalid_inputargs test 5');
            clear foobar
            testCase.verifyWarning(@()pspm_load_data('fn', {1}), 'ID:invalid_input', 'invalid_inputargs test 6');
            struct.data = cell(3,1);
            testCase.verifyWarning(@()pspm_load_data(struct), 'ID:invalid_input', 'invalid_inputargs test 7');
            testCase.verifyWarning(@()pspm_load_data(pspm_load_data_test.fn, 250), 'ID:invalid_input', 'invalid_inputargs test 8');
        end
        
        function invalid_datafile(testCase)
            fn2 = 'testdatafile898465.mat';
            if exist(fn2, 'file'), delete(fn2); end;
            testCase.verifyWarning(@()pspm_load_data(fn2), 'ID:nonexistent_file', 'invalid_datafile test 1');

            load(pspm_load_data_test.fn);
            
            save(fn2, 'data');
            testCase.verifyWarning(@()pspm_load_data(fn2), 'ID:invalid_data_structure', 'invalid_datafile test 2');
            
            save(fn2, 'infos');
            testCase.verifyWarning(@()pspm_load_data(fn2), 'ID:invalid_data_structure', 'invalid_datafile test 3');
            
            fulldata = data;
            data{2} = rmfield(fulldata{2}, 'data');
            save(fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(fn2), 'ID:invalid_data_structure', 'invalid_datafile test 4');
            
            data = fulldata;
            data{3} = rmfield(fulldata{3}, 'header');
            save(fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(fn2), 'ID:invalid_data_structure', 'invalid_datafile test 5');
            
            data = fulldata;
            data{7}.header = rmfield(fulldata{7}.header, 'sr');
            save(fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(fn2), 'ID:invalid_data_structure', 'invalid_datafile test 6');
            
            data = fulldata;
            data{4}.data = [data{4}.data data{4}.data];
            save(fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(fn2), 'ID:invalid_data_structure', 'invalid_datafile test 7');
            
            data = fulldata;
            data{1}.data = [data{1}.data; 1;1;1;1];
            save(fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(fn2), 'ID:invalid_data_structure', 'invalid_datafile test 8');
            
            data = fulldata;
            data{2}.data = [data{2}.data; infos.duration+0.1];
            save(fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(fn2), 'ID:invalid_data_structure', 'invalid_datafile test 9');
            
            data = fulldata;
            data{5}.header.chantype = 'scanner';
            save(fn2, 'infos', 'data');
            testCase.verifyWarning(@()pspm_load_data(fn2), 'ID:invalid_data_structure', 'invalid_datafile test 10');
            
            data = fulldata;
            data{2}.data = [data{2}.data; infos.duration+0.1];
            chan.infos = infos; chan.data = data; chan.options.overwrite = 1;
            testCase.verifyWarning(@()pspm_load_data(fn2, chan), 'ID:invalid_data_structure', 'invalid_datafile test 11');
            
            clear infos data chan
            delete(fn2);
        end
        
        %return all channels
        function valid_datafile_0(testCase)
            [sts, infos, data] = pspm_load_data(pspm_load_data_test.fn);
            act_val.infos = infos;
            act_val.data = data;
            
            exp_val = load(pspm_load_data_test.fn);
            
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_0 test 1');
        end
        
        %return all channels when input is a struct
        function valid_datafile_1(testCase)
            struct = load(pspm_load_data_test.fn);
            [sts, infos, data] = pspm_load_data(struct);
            act_val.infos = infos;
            act_val.data = data;
            
            exp_val = load(pspm_load_data_test.fn);
            
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_0 test 1');
        end
        
        %return one channel
        function valid_datafile_2(testCase)
            chan = 2;
            
            [sts, infos, data] = pspm_load_data(pspm_load_data_test.fn, chan);
            act_val.infos = infos;
            act_val.data = data;
            
            exp_val = load(pspm_load_data_test.fn);
            exp_val.data = exp_val.data(chan);
            
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_1 test 1');
        end
        
        %return multiple channels
        function valid_datafile_3(testCase)
            chan = [3 5];
            
            [sts, infos, data] = pspm_load_data(pspm_load_data_test.fn, chan);
            act_val.infos = infos;
            act_val.data = data;
            
            exp_val = load(pspm_load_data_test.fn);
            exp_val.data = exp_val.data(chan);
            
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_2 test 1');
        end
        
        %return scr channels
        function valid_datafile_4(testCase)
            chan = 'scr';
            
            [sts, infos, data] = pspm_load_data(pspm_load_data_test.fn, chan);
            act_val.infos = infos;
            act_val.data = data;
            
            exp_val = load(pspm_load_data_test.fn);
            exp_val.data = exp_val.data(testCase.pspm_channels);
            
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_3 test 1');
        end
        
        %return event channels
        function valid_datafile_5(testCase)
            chan = 'events';
            
            [sts, infos, data] = pspm_load_data(pspm_load_data_test.fn, chan);
            act_val.infos = infos;
            act_val.data = data;
            
            exp_val = load(pspm_load_data_test.fn);
            exp_val.data = exp_val.data(testCase.event_channels);
            
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_4 test 1');
        end
        
        % save data
        function valid_datafile_6(testCase)
            chan = 0;
            [sts, infos, data] = pspm_load_data(pspm_load_data_test.fn, chan); % load
            fn2 = 'testdatafile898465.mat';
            save.data = data;
            save.infos = infos;
            save.options.overwrite = 1;
            sts = pspm_load_data(fn2, save);                                 % save in different file
            
            [sts, infos, data] = pspm_load_data(fn2, chan);% load again
            act_val.infos = infos;
            act_val.data = data;
            exp_val = load(pspm_load_data_test.fn);
            
            import matlab.unittest.constraints.IsEqualTo;
            testCase.verifyThat(act_val, IsEqualTo(exp_val), 'valid_datafile_5 test 1');
            delete(fn2);
            clear save
        end
        
        
    end
    
    
end

