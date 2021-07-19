classdef pspm_write_channel_test < matlab.unittest.TestCase
    
    % pspm_write_channel_test
    % unittest class for the pspm_write_channel function
    
    % (C) 2015 Tobias Moser (University of Zurich)
    % Reviewed: July 2021 Teddy (WCHN, UCL)
    
    properties
        fn1 = 'testdatafile_write_channel';
    end
    
    methods(TestClassSetup) % Setup
        function generate_testdatafile(this)
            data_settings = struct(); % initialise data settings
            filename = [this.fn1, '.mat'];
            % filename = pspm_find_free_fn(this.fn1, '.mat'); % set data settings
            % The use of pspm_find_free_fn will lead to undetected name
            % of the test data file. I am not sure it is mandatory to use
            % pspm_find_free_fn here, but I would recommend to use a fixed
            % file name for testing. (Teddy, 19-07-2021)
            data_settings.fn = filename;
            c{1}.chantype = 'scr';
            c{2}.chantype = 'marker';
            c{3}.chantype = 'scr';
            c{4}.chantype = 'gaze_x_l';
            c{4}.units = 'mm';
            data_settings.channels = c;
            data_settings.sr = 100;
            data_settings.duration = 500;
            pspm_testdata_gen(data_settings.channels, data_settings.duration, filename); % generate aquisition data
            this.fn1 = filename;
        end
    end
    
    methods % Verification
        function verify_write(this, new, old, gen_data, action, outinfos)
            sign = 1;
            if ~strcmpi(action, 'replace')
                if strcmp(action, 'delete')
                    sign = -1;
                end
                this.verifyTrue((numel(new.data) - numel(old.data)) == sign*numel(outinfos.channel));
            else
                this.verifyEqual(numel(new.data), numel(old.data));
            end
            
            % sanity check, so check wont fail if there is no history
            if ~isfield(old.infos, 'history')
                old.infos.history = {};
            end
            this.verifyTrue((numel(new.infos.history) - numel(old.infos.history)) == 1);
            
            % some more checks for 'replace' and 'add'
            if ~strcmpi(action, 'delete')
                added_chan = gen_data.data{1};
                % look for channel with same chantype
                chan = cellfun(@(f) strcmpi(f.header.chantype, added_chan.header.chantype), new.data);
                if numel(find(chan)) == 1
                    new_chan = new.data{chan};
                elseif numel(find(chan)) > 1
                    % this should not happen (the function is only in use when
                    % only one channeltype is in the testdatafile)
                    % because this testfunction works with only one channel
                    % type
                    warning('More than one channel with chantype %s found.', added_chan.header.chantype);
                else
                    warning('No channel found with chantype %s.', added_chan.header.chantype);
                end
                
                % ensure returned channel id is equal to the channel looked
                % for
                this.verifyEqual(find(chan), outinfos.channel);
                
                % same amount of data
                this.verifyEqual(numel(new_chan.data), numel(added_chan.data));
                % same sr
                this.verifyEqual(new_chan.header.sr, added_chan.header.sr);
            end
        end
    end
    
    methods(Test)
        function invalid_input(this)
            this.verifyWarning(@()pspm_write_channel(), 'ID:invalid_input');
            this.verifyWarning(@()pspm_write_channel(1), 'ID:invalid_input');
            this.verifyWarning(@()pspm_write_channel('some_file', []), 'ID:unknown_action');
            this.verifyWarning(@()pspm_write_channel('some_file', [], ''), 'ID:unknown_action');
            options = struct();
            options.channel = 'some invalid channel';
            this.verifyWarning(@()pspm_write_channel('some_file', [], 'add', options), 'ID:invalid_input');
            options.channel = -1;
            this.verifyWarning(@()pspm_write_channel('some_file', [], 'add', options), 'ID:invalid_input');
            options.channel = 0;
            this.verifyWarning(@()pspm_write_channel('some_file', [], 'delete', options), 'ID:invalid_input');
            this.verifyWarning(@()pspm_write_channel('some_file', [], 'add', options), 'ID:invalid_input');
            this.verifyWarning(@()pspm_write_channel('some_file', 1:3, 'add', options), 'ID:invalid_input');
            options.channel = 1:5;
            this.verifyWarning(@()pspm_write_channel(this.fn1, [], 'delete', options), 'ID:invalid_input');
            options.channel = 'ecg';
            this.verifyWarning(@()pspm_write_channel(this.fn1, [], 'delete', options), 'ID:no_matching_channels');
            c{1}.chantype = 'hb';
            c{1}.sr = 200;
            gen_data = pspm_testdata_gen(c, 500);
            d = gen_data.data{1}.data;
            gen_data.data{1}.data = [d,d];
            this.verifyWarning(@()pspm_write_channel(this.fn1, gen_data.data{1}, 'add'), 'ID:invalid_data_structure');
        end
        
        function test_add(this)
            c{1}.chantype = 'hb';
            c{1}.sr = 200;
            gen_data = pspm_testdata_gen(c, 500); % generate new channel
            [~, old.infos, old.data] = pspm_load_data(this.fn1); % load previously generated file
            [~, outinfos] = this.verifyWarningFree(@()pspm_write_channel(this.fn1, gen_data.data{1}, 'add'));% add channel
            [~, new.infos, new.data] = pspm_load_data(this.fn1);  % load changed data
            this.verifyWarningFree(@() this.verify_write(new, old, gen_data, 'add', outinfos));
        end
        
        function test_add_transposed(this)
            c{1}.chantype = 'rs';
            c{1}.sr = 200;
            gen_data = pspm_testdata_gen(c, 500); % generate new channel
            [~, old.infos, old.data] = pspm_load_data(this.fn1); % load file before
            gen_data.data{1}.data = gen_data.data{1}.data'; % transpose
            [~, outinfos] = this.verifyWarning(@()pspm_write_channel(this.fn1, gen_data.data{1}, 'add'), 'ID:invalid_data_structure'); % add channel
            [~, new.infos, new.data] = pspm_load_data(this.fn1); % load changed data
            this.verifyWarningFree(@() this.verify_write(new, old, gen_data, 'add', outinfos));
        end
        
        function test_replace_add(this)
            % generate new channel
            c{1}.chantype = 'hr';
            c{1}.sr = 10;
            gen_data = pspm_testdata_gen(c, 500);
            
            % load file before
            [~, old.infos, old.data] = pspm_load_data(this.fn1);
            
            % channel should not exist -> should fall into 'add' action
            [~, outinfos] = this.verifyWarningFree(@() pspm_write_channel(this.fn1, gen_data.data{1}, 'replace'));
            
            % load changed data
            [~, new.infos, new.data] = pspm_load_data(this.fn1);
            
            this.verifyWarningFree(@() this.verify_write(new, old, gen_data, 'add', outinfos));
        end
        
        function test_replace(this)
            % change channel setting and regenerate data
            c{1}.chantype = 'hr';
            c{1}.sr = 20;
            gen_data = pspm_testdata_gen(c, 500);
            
            % load file before
            [~, old.infos, old.data] = pspm_load_data(this.fn1);
            
            % channel should exist -> should actually replace
            [~, outinfos] = this.verifyWarningFree(@() pspm_write_channel(this.fn1, gen_data.data{1}, 'replace'));
            
            % load changed data
            [~, new.infos, new.data] = pspm_load_data(this.fn1);
            
            % check if has been replaced
            this.verifyWarningFree(@() this.verify_write(new, old, gen_data, 'replace', outinfos));
        end
        
        function test_replace_units(this)
            % change channel setting and regenerate data
            c{1}.chantype = 'gaze_x_l';
            c{1}.units = 'mm';
            c{1}.sr = 20;
            gen_data = pspm_testdata_gen(c, 500);
            
            % load file before
            [~, old.infos, old.data] = pspm_load_data(this.fn1);
            
            % channel should exist -> should actually replace
            [~, outinfos] = this.verifyWarningFree(@() pspm_write_channel(this.fn1, gen_data.data{1}, 'replace'));
            
            % load changed data
            [~, new.infos, new.data] = pspm_load_data(this.fn1);
            
            % check if has been replaced
            this.verifyWarningFree(@() this.verify_write(new, old, gen_data, 'replace', outinfos));
            
            % change units
            gen_data.data{1}.header.units = 'degree';
            [~, ~] = this.verifyWarningFree(@() pspm_write_channel(this.fn1, gen_data.data{1}, 'replace'));
            [~, post_unit_change.infos, post_unit_change.data] = pspm_load_data(this.fn1);
            
            % should be one more channel as degrees did not exist
            this.verifyEqual(length(post_unit_change.data), length(new.data) + 1);
            
            % assert one mm gaze channel and one degree gaze channel
            this.verifyEqual(length(find(cellfun(@(c) strcmp(c.header.units, 'mm') && strcmp(c.header.chantype, 'gaze_x_l'), post_unit_change.data))), 1);
            this.verifyEqual(length(find(cellfun(@(c) strcmp(c.header.units, 'degree') && strcmp(c.header.chantype, 'gaze_x_l'), post_unit_change.data))), 1);
            
        end
        
        function test_delete_single(this)
            
            % -------------------------------------------------------------
            % Delete with chantype
            
            % prepare
            data.header.chantype = 'hr';
            
            % load file before
            [~, old.infos, old.data] = pspm_load_data(this.fn1);
            
            % run delete
            [~, outinfos] = this.verifyWarningFree(@() pspm_write_channel(this.fn1, data, 'delete'));
            
            % load changed data
            [~, new.infos, new.data] = pspm_load_data(this.fn1);
            
            % do basic checks
            this.verify_write(new, old, [], 'delete', outinfos);
            this.verifyEqual(numel(outinfos.channel), 1);
            
            % search channel hr (should be deleted)
            chan = cellfun(@(f) strcmpi(f.header.chantype, 'hr'), new.data);
            this.verifyTrue(~any(chan));
            
            % -------------------------------------------------------------
            % Delete with channr
            
            options.channel = numel(new.data);
            % new is now old
            old = new;
            
            [~, outinfos] = this.verifyWarningFree(@() pspm_write_channel(this.fn1, [], 'delete', options));
            
            % load changed data
            [~, new.infos, new.data] = pspm_load_data(this.fn1);
            
            % do basic checks
            this.verify_write(new, old, [], 'delete', outinfos);
            this.verifyEqual(numel(outinfos.channel), 1);
            
            % -------------------------------------------------------------
            % Test delete algorithm
            % will then also be needed for test_delete_multi
            
            % prepare (add some resp channels)
            c = cell(1,7);
            for i=1:7
                % all resp channels
                c{i}.chantype = 'resp';
                % allows to identify the channel again easily
                c{i}.sr = i*10;
            end
            
            gen_data = pspm_testdata_gen(c, 500);
            this.verifyWarningFree(@() pspm_write_channel(this.fn1, gen_data.data, 'add'));
            
            % try to delete one with delete option last
            
            % load file before
            [~, old.infos, old.data] = pspm_load_data(this.fn1);
            
            % delete last occurence
            options = struct();
            options.delete = 'last';
            options.channel = 'resp';
            [~, outinfos] = this.verifyWarningFree(@() pspm_write_channel(this.fn1, [], 'delete', options));
            
            % load changed data
            [~, new.infos, new.data] = pspm_load_data(this.fn1);
            
            % do basic checks
            this.verify_write(new, old, [], 'delete', outinfos);
            this.verifyEqual(numel(outinfos.channel), 1);
            
            % ensure last entry was deleted
            this.verifyEqual(new.data{end}.header.sr, 60);
            
            % new becomes old
            old = new;
            options.delete = 'first';
            options.channel = 'resp';
            [~, outinfos] = this.verifyWarningFree(@() pspm_write_channel(this.fn1, [], 'delete', options));
            
            % load changed data
            [~, new.infos, new.data] = pspm_load_data(this.fn1);
            
            % do basic checks
            this.verify_write(new, old, [], 'delete', outinfos);
            this.verifyEqual(numel(outinfos.channel), 1);
            
            % ensure first entry was deleted
            this.verifyEqual(new.data{end}.header.sr, 60);
        end
        
        function test_delete_multi(this)
            % work with file earlier filled with resp channels
            
            % -------------------------------------------------------------
            % remove first two channels
            
            % load file before
            [~, old.infos, old.data] = pspm_load_data(this.fn1);
            
            % delete last occurence
            options = struct();
            options.channel = 1:2;
            [~, outinfos] = this.verifyWarningFree(@() pspm_write_channel(this.fn1, [], 'delete', options));
            
            % load changed data
            [~, new.infos, new.data] = pspm_load_data(this.fn1);
            
            % verify
            % do basic checks
            this.verify_write(new, old, [], 'delete', outinfos);
            this.verifyEqual(numel(outinfos.channel), 2);
            
            % -------------------------------------------------------------
            % remove remaining 'resp' channels
            
            old = new;
            
            chan = cellfun(@(f) strcmpi(f.header.chantype, 'resp'), new.data);
            if find(chan) <= 1
                % add some more 'resp' channels
                c = cell(1,7);
                for i=1:7
                    % all resp channels
                    c{i}.chantype = 'resp';
                    % allows to identify the channel again easily
                    c{i}.sr = 10;
                end
                
                gen_data = pspm_testdata_gen(c, 500);
                this.verifyWarningFree(@() pspm_write_channel(this.fn1, gen_data.data, 'add'));
            end
            
            options.channel = 'resp';
            options.delete = 'all';
            [~, outinfos] = this.verifyWarningFree(@() pspm_write_channel(this.fn1, [], 'delete', options));
            
            % load changed data
            [~, new.infos, new.data] = pspm_load_data(this.fn1);
            
            % do basic checks
            this.verify_write(new, old, [], 'delete', outinfos);
            
            % verify
            chan = cellfun(@(f) strcmpi(f.header.chantype, 'resp'), new.data);
            this.verifyTrue(~any(chan));
        end
    end
    
    methods(TestClassTeardown) % Clearance
        function cleanup(this) % responsible to clean up the dirt that has been made
            if ~isempty(this.fn1)
                delete(this.fn1);
            end
        end
    end
    
end