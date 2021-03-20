classdef pspm_split_sessions_test < matlab.unittest.TestCase
% SCR_SPLIT_SESSIONS_TEST 
% unittest class for the pspm_split_sessions function
%__________________________________________________________________________
% SCRalyze TestEnvironment
% (C) 2013 Linus Rüttimann (University of Zurich)

    properties
        expected_number_of_files = 3;
        data_fn = 'datafile';
    end
    
    properties (TestParameter)
        nsessions = {2,5}
        prefix = {-1,-5,-15}
        suffix = {3,9,12}
        splitpoints = {[2 5 7 9 11],[10 20 33 35 60 80 90 100 111 114 116 120],[]}
    end
        
    methods (Test)
        function invalid_input(this)
            this.verifyWarning(@()pspm_split_sessions(), 'ID:invalid_input');
            this.verifyWarning(@()pspm_split_sessions(2), 'ID:invalid_input');
            this.verifyWarning(@()pspm_split_sessions('fn', 'foo'), 'ID:invalid_input'); 
        end
        
        function one_datafile(this)
            fn = 'testdatafile0.mat';
            
            channels{1}.chantype = 'scr';
            channels{2}.chantype = 'hb';
            channels{3}.chantype = 'marker';
            datastruct = pspm_testdata_gen(channels, 100);
            datastruct.data{3}.data = [1 4 9 12 30 31 34 41 43 59 65 72 74 80 89 96]'; %with default values MAXSN=10 & BRK2NORM=3 the datafile should be split into 3 files
            pspm_load_data(fn, datastruct); %save datafile
            %datafile.data{3}.data = [0 1]';
            %save(fn, '-struct', 'datafile');
            
            newdatafile = pspm_split_sessions(fn);
            
            this.verifyTrue(numel(newdatafile) == this.expected_number_of_files, sprintf('the testdatafile %s has been split into %i files and not like expected into %i files', fn, numel(newdatafile), this.expected_number_of_files));
            
            for k=1:numel(newdatafile)
                [sts, infos, data] = pspm_load_data(newdatafile{k});
                this.verifyTrue(sts == 1, sprintf('couldn''t load file %s with pspm_load_data', newdatafile{k}));
                this.verifyTrue(numel(data) == numel(channels), sprintf('number of channels doesn''t match in file %s', newdatafile{k}));
                this.verifyTrue(isfield(infos, 'splitdate'), sprintf('there is no field infos.splitdate in file %s', newdatafile{k}));
                this.verifyTrue(isfield(infos, 'splitsn'), sprintf('there is no field infos.splitsn in file %s', newdatafile{k}));
                this.verifyTrue(isfield(infos, 'splitfile'), sprintf('there is no field infos.splitfile in file %s', newdatafile{k}));
                
                delete(newdatafile{k});
            end
            
            delete(fn);
        end
        
        function multiple_datafiles(this)
            fn{1} = 'testdatafile1.mat';
            fn{2} = 'testdatafile2.mat';
            
            channels{1}.chantype = 'scr';
            channels{2}.chantype = 'hb';
            channels{3}.chantype = 'marker';
            datastruct = pspm_testdata_gen(channels, 100);
            datastruct.data{3}.data = [1 4 9 12 30 31 34 41 43 59 65 72 74 80 89 96]'; %with default values MAXSN=10 & BRK2NORM=3 the datafile should be split into 3 files
            
            for m=1:numel(fn)
                pspm_load_data(fn{m}, datastruct); %save datafile
            end
            
            newdatafile = pspm_split_sessions(fn, 3);
            
            this.verifyTrue(numel(fn) == numel(newdatafile));
            
            for m=1:numel(fn)
                this.verifyTrue(numel(newdatafile{m}) == this.expected_number_of_files, sprintf('the testdatafile %s has been split into %i files and not like expected into %i files', fn{m}, numel(newdatafile{m}), this.expected_number_of_files));
                for k=1:numel(newdatafile{m})
                    [sts, infos, data] = pspm_load_data(newdatafile{m}{k});
                    this.verifyTrue(sts == 1, sprintf('couldn''t load file %s with pspm_load_data', newdatafile{m}{k}));
                    this.verifyTrue(numel(data) == numel(channels), sprintf('number of channels doesn''t match in file %s', newdatafile{m}{k}));
                    this.verifyTrue(isfield(infos, 'splitdate'), sprintf('there is no field infos.splitdate in file %s', newdatafile{m}{k}));
                    this.verifyTrue(isfield(infos, 'splitsn'), sprintf('there is no field infos.splitsn in file %s', newdatafile{m}{k}));
                    this.verifyTrue(isfield(infos, 'splitfile'), sprintf('there is no field infos.splitfile in file %s', newdatafile{m}{k}));

                    delete(newdatafile{m}{k});
                end
            
                delete(fn{m});
            end
        end
        
        function test_dynamic_sessions(this, nsessions)
            fn = pspm_find_free_fn(this.data_fn, '.mat');
            channels{1}.chantype = 'scr';
            channels{2}.chantype = 'hb';
            channels{3}.chantype = 'marker';
            channels{3}.sessions = nsessions;
            channels{3}.session_distance = 10;
            channels{3}.variance = 0.05;

            % 6 minutes data
            pspm_testdata_gen(channels, 60*6, fn);            
            newdatafile = pspm_split_sessions(fn, 3);
            
            this.verifyEqual(numel(newdatafile), nsessions);
            
            for i = 1:numel(newdatafile)
                [~, ~, d] = pspm_load_data(newdatafile{i});
                this.verifyEqual(d{3}.data(1), 0);
                if exist(newdatafile{i}, 'file')
                    delete(newdatafile{i});
                end
            end
            
            if exist(fn, 'file')
                delete(fn);
            end
        end
    
        function test_appendices(this, prefix, suffix)
            fn = pspm_find_free_fn(this.data_fn, '.mat');
            channels{1}.chantype = 'scr';
            channels{2}.chantype = 'hb';
            channels{3}.chantype = 'marker';
            channels{3}.sessions = 10;
            channels{3}.session_distance = 10;
            channels{3}.variance = 0.05;
            
            % 6 minutes data
            data = pspm_testdata_gen(channels, 60*6, fn);
            options = struct('prefix', prefix, 'suffix', suffix);
            newdatafile = pspm_split_sessions(fn, 3, options);
            
            this.verifyEqual(numel(newdatafile),10);
            
            for i = 1:numel(newdatafile)
                if exist(newdatafile{i}, 'file')
                    % test suffix and prefix
                    [~, info, d] = pspm_load_data(newdatafile{i});
                    if i ~= 1
                        this.verifyEqual(d{3}.data(1), -prefix);
                    end
                    
                    if i ~= numel(newdatafile)
                        this.verifyEqual(d{3}.data(end), info.duration - (suffix + mean(diff(d{3}.data))), 'RelTol', 10^-2);
                    end
                    % remove file
                    delete(newdatafile{i});
                end
            end
            
            if exist(fn, 'file')
                delete(fn);
            end
        end
        
        function test_splitpoints(this, splitpoints)
            
            n_sess = 10;
            sess_dist = 10;
            
            fn = pspm_find_free_fn(this.data_fn, '.mat');
            channels{1}.chantype = 'scr';
            channels{2}.chantype = 'hb';
            channels{3}.chantype = 'marker';
            channels{3}.sessions = n_sess;
            channels{3}.session_distance = sess_dist;
            channels{3}.variance = 0.05;
            
            % 6 minutes data
            dur = 60*6;
            
            data = pspm_testdata_gen(channels, dur, fn);
            split_times = data.data{3}.data(splitpoints)';
            
            if isempty(splitpoints)
                sess_dur = repmat((dur - n_sess*sess_dist)/n_sess, 1, n_sess);
            else
                starts = [1 split_times];
                ends = [split_times dur];
                
                sess_dur = diff([starts; ends]);
            end
            
            options.splitpoints = splitpoints;
            newdatafile = pspm_split_sessions(fn, 3, options);
            if ~isempty(splitpoints)
                n_sess_exp = numel(splitpoints)+1;
            else
                n_sess_exp = 10;
            end
            this.verifyEqual(numel(newdatafile),n_sess_exp);
            
            
            for i = 1:numel(newdatafile)
               
                if exist(newdatafile{i}, 'file')
                    % test suffix and prefix
                    [~, info, ~] = pspm_load_data(newdatafile{i});
                    this.verifyEqual(info.duration, sess_dur(i), 'RelTol', 0.5);
                    
                    % remove file
                    delete(newdatafile{i});
                end
            end
            
            if exist(fn, 'file')
                delete(fn);
            end
        end
    end
    
end
