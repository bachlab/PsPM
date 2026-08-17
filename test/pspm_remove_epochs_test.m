classdef pspm_remove_epochs_test < pspm_testcase
% ● Description
%   Unit test class for the pspm_remove_epochs function.
% ● Authorship
%   (C) 2026 Bernhard Agoué von Raußendorf

properties(Constant)
    % Define test data filenames
    epochs_filename = 'test_remove_epochs.mat';
    data_filename = 'test_remove_data.mat';
    backup_data_filename = 'test_remove_data_backup.mat';
    event_filename = 'test_remove_event_data.mat';
    backup_event_filename = 'test_remove_event_data_backup.mat';
end

methods(TestClassSetup)
function generate_test_data(this)
    % Generate test epochs file
    epochs = [5, 10; 15, 20];
    save(this.epochs_filename, 'epochs');

    % Generate continuous test data file (scr)
    channels{1}.chantype = 'scr';
    channels{1}.sr = 100;
    duration = 25; % seconds
    pspm_testdata_gen(channels, duration, this.data_filename);
    
    % Backup the continuous data file
    copyfile(this.data_filename, this.backup_data_filename);

    % Generate event test data file (marker)
    ev_channels{1}.chantype = 'marker';
    ev_channels{1}.eventrt = 1; % 1 event per second
    pspm_testdata_gen(ev_channels, duration, this.event_filename);
    
    % Backup the event data file
    copyfile(this.event_filename, this.backup_event_filename);
end
end

methods(Test)
    function InValidInputError(this)
        % no input
        this.verifyWarning(@() pspm_remove_epochs(), 'ID:invalid_input');
        % not enough input
        this.verifyWarning(@() pspm_remove_epochs('file.mat'), 'ID:invalid_input');
        this.verifyWarning(@() pspm_remove_epochs(this.data_filename), 'ID:invalid_input');
        % invalid data file
        this.verifyWarning(@() pspm_remove_epochs('nofile.mat', 1, this.epochs_filename), 'ID:invalid_input');
        % invalid epoch file
        this.verifyWarning(@() pspm_remove_epochs(this.data_filename, 1, 'noepoch.mat'), 'ID:nonexistent_file');
    end

    function InValidExpandEpochsWarning(this)
        % Tests that invalid expand_epochs issues a warning but continues
        options = struct('channel_action', 'replace', 'expand_epochs', [1]); % Invalid 1-element vector
        copyfile(this.backup_data_filename, this.data_filename); % Ensure fresh file
        
        % function [sts, outchannel] = pspm_remove_epochs(datafile, channel, epochfile, options)



        % Should issue the specific warning
        this.verifyWarning(@()pspm_remove_epochs(this.data_filename, 1, this.epochs_filename, options) , 'ID:invalid_epochs');
        
        % Restore the datafile
        copyfile(this.backup_data_filename, this.data_filename);
    end
    
    function InValidExpandEpochsContiues(this)
        % Tests that invalid expand_epochs issues a warning but continues
        options = struct('channel_action', 'replace', 'expand_epochs', [1]); % Invalid 1-element vector
        copyfile(this.backup_data_filename, this.data_filename); % Ensure fresh file


        % Should issue the specific warning
        % this.verifyWarning(@()pspm_remove_epochs(this.data_filename, 1, this.epochs_filename, options) , 'ID:invalid_epochs');

        % Run the function
        [sts, out_channel] = pspm_remove_epochs(this.data_filename, 1, this.epochs_filename, options);
        this.verifyEqual(sts, 1);
        this.verifyEqual(out_channel, 1);

        % Load the data and check that epochs are set to NaN
        [~, ~, data, filestruct] = pspm_load_data(this.data_filename, 'none');
        this.verifyEqual(filestruct.numofchan, 1); % Ensure no channel was added
        
        sr = data{1}.header.sr;
        data_values = data{1}.data;

        % Check NaNs in 5-10s and 15-20s (not expanded)
        idx_1 = round(5*sr):round(10*sr);
        idx_2 = round(15*sr):round(20*sr);
        
        this.verifyTrue(all(isnan(data_values(idx_1))));
        this.verifyTrue(all(isnan(data_values(idx_2))));
        
        % Check that data outside epochs is NOT NaN 
        idx_3 = round(1*sr):round(4*sr);
        this.verifyFalse(any(isnan(data_values(idx_3))));

        % Restore the datafile
        copyfile(this.backup_data_filename, this.data_filename);
    end
    
    function ContinuousDataReplaceTest(this)
        % Test removing epochs with 'replace' option on continuous data
        options = struct('channel_action', 'replace');

        %this.verifyWarning(@()pspm_remove_epochs(this.data_filename, 1, this.epochs_filename, options), 'ID:invalid_input');
        
        copyfile(this.backup_data_filename, this.data_filename); % Ensure fresh file

        % Run the function
        [sts, out_channel] = pspm_remove_epochs(this.data_filename, 1, this.epochs_filename, options);
        this.verifyEqual(sts, 1);
        this.verifyEqual(out_channel, 1);

        % Load the data and check that epochs are set to NaN
        [~, ~, data, filestruct] = pspm_load_data(this.data_filename, 'none');
        this.verifyEqual(filestruct.numofchan, 1); % Ensure no channel was added
        
        sr = data{1}.header.sr;
        data_values = data{1}.data;

        % Check NaNs in 5-10s and 15-20s
        idx_1 = round(5*sr):round(10*sr);
        idx_2 = round(15*sr):round(20*sr);
        
        this.verifyTrue(all(isnan(data_values(idx_1))));
        this.verifyTrue(all(isnan(data_values(idx_2))));
        
        % Check that data outside epochs is NOT NaN 
        idx_3 = round(1*sr):round(4*sr);
        this.verifyFalse(any(isnan(data_values(idx_3))));

        % Restore the datafile
        copyfile(this.backup_data_filename, this.data_filename);
    end

    function ContinuousDataAddTest(this)
        % Test removing epochs with 'add' option on continuous data
        options = struct('channel_action', 'add');
        copyfile(this.backup_data_filename, this.data_filename); % Ensure fresh file

        % Run the function
        [sts, out_channel] = pspm_remove_epochs(this.data_filename, 1, this.epochs_filename, options);
        this.verifyEqual(sts, 1);
        this.verifyEqual(out_channel, 2); % Should be added as channel 2

        % Load the data and check structure
        [~, ~, data, filestruct] = pspm_load_data(this.data_filename, 'none');
        this.verifyEqual(filestruct.numofchan, 2); % Ensure channel was added
        
        sr = data{2}.header.sr;
        data_values = data{2}.data;

        % Check NaNs in 5-10s and 15-20s for the NEW channel
        idx_1 = round(5*sr):round(10*sr);
        idx_2 = round(15*sr):round(20*sr);
        
        this.verifyTrue(all(isnan(data_values(idx_1))));
        this.verifyTrue(all(isnan(data_values(idx_2))));
        
        % Check original channel is untouched (no NaNs)
        this.verifyFalse(any(isnan(data{1}.data)));

        % Restore the datafile
        copyfile(this.backup_data_filename, this.data_filename);
    end

    function ExpandEpochsContinuousTest(this)
        % Test expanding epochs by [1, 1] seconds
        options = struct('channel_action', 'replace', 'expand_epochs', [1, 1]);
        copyfile(this.backup_data_filename, this.data_filename); % Ensure fresh file

        % Run the function
        [sts, out_channel] = pspm_remove_epochs(this.data_filename, 1, this.epochs_filename, options);
        this.verifyEqual(sts, 1);

        % Load the data
        [~, ~, data] = pspm_load_data(this.data_filename, out_channel);
        sr = data{1}.header.sr;
        data_values = data{1}.data;

        % Check NaNs in expanded epochs: 4-11s and 14-21s
        idx_1 = round(4*sr):round(11*sr);
        idx_2 = round(14*sr):round(21*sr);
        
        this.verifyTrue(all(isnan(data_values(idx_1))));
        this.verifyTrue(all(isnan(data_values(idx_2))));
        
        % Check borders are NOT NaN
        idx_3 = round(3.9*sr);
        idx_4 = round(11.1*sr);
        this.verifyFalse(isnan(data_values(idx_3)));
        this.verifyFalse(isnan(data_values(idx_4)));

        % Restore the datafile
        copyfile(this.backup_data_filename, this.data_filename);
    end

    function EventDataReplaceTest(this)
        % Test removing epochs on event data (markers)
        options = struct('channel_action', 'replace');
        copyfile(this.backup_event_filename, this.event_filename); % Ensure fresh file

        % Run the function
        [sts, out_channel] = pspm_remove_epochs(this.event_filename, 1, this.epochs_filename, options);
        this.verifyEqual(sts, 1);
        this.verifyEqual(out_channel, 1);

        % Load the data
        [~, ~, data] = pspm_load_data(this.event_filename, out_channel);
        events = data{1}.data;

        % Verify no events exist between 5-10s and 15-20s
        this.verifyFalse(any(events >= 5 & events <= 10));
        this.verifyFalse(any(events >= 15 & events <= 20));
        
        % Verify events outside the epochs still exist
        this.verifyTrue(any(events < 5));
        this.verifyTrue(any(events > 10 & events < 15));
        this.verifyTrue(any(events > 20));

        % Restore the datafile
        copyfile(this.backup_event_filename, this.event_filename);
    end
    
    function EventDataAddTest(this)
        % Test removing epochs on event data (markers)
        options = struct('channel_action', 'add');
        copyfile(this.backup_event_filename, this.event_filename); % Ensure fresh file

        % Run the function
        [sts, out_channel] = pspm_remove_epochs(this.event_filename, 1, this.epochs_filename, options);
        this.verifyEqual(sts, 1);
        this.verifyEqual(out_channel, 2);

        % Load the data
        [~, ~, data] = pspm_load_data(this.event_filename, out_channel);
        events = data{1}.data;

        % Verify no events exist between 5-10s and 15-20s
        this.verifyFalse(any(events >= 5 & events <= 10));
        this.verifyFalse(any(events >= 15 & events <= 20));

        % Verify events outside the epochs still exist
        this.verifyTrue(any(events < 5));
        this.verifyTrue(any(events > 10 & events < 15));
        this.verifyTrue(any(events > 20));

        % Restore the datafile
        copyfile(this.backup_event_filename, this.event_filename);
    end
    
    function EventDataAddTestExpandEpochs(this)
        % Test removing epochs on event data (markers)
        options = struct('channel_action', 'add', 'expand_epochs', [1, 1]);
        copyfile(this.backup_event_filename, this.event_filename); % Ensure fresh file

        % Run the function
        [sts, out_channel] = pspm_remove_epochs(this.event_filename, 1, this.epochs_filename, options);
        this.verifyEqual(sts, 1);
        this.verifyEqual(out_channel, 2);

        % Load the data
        [~, ~, data] = pspm_load_data(this.event_filename, out_channel);
        events = data{1}.data;

        % Verify no events exist between 5-10s and 15-20s
        this.verifyFalse(any(events >= 4 & events <= 11));
        this.verifyFalse(any(events >= 14 & events <= 21));

        % Verify events outside the epochs still exist
        this.verifyTrue(any(events < 4));
        this.verifyTrue(any(events > 11 & events < 16));
        this.verifyTrue(any(events > 21));

        % Restore the datafile
        copyfile(this.backup_event_filename, this.event_filename);
    end
    
    % add outsite the file length
    function ContinuousEpochsOutsideFileLengthTest(this)
        % Test epochs that are outside the data length
        % epochs = [-5, 5; 20, 30; 40, 50];
        epochs = [20, 30; 40, 50];
        outside_epoch_file = 'test_remove_epochs_outside.mat';
        save(outside_epoch_file, 'epochs');
    
        options = struct('channel_action', 'replace');
        copyfile(this.backup_data_filename, this.data_filename);
    
        [sts, out_channel] = pspm_remove_epochs(this.data_filename, 1, outside_epoch_file, options);
        this.verifyEqual(sts, 1);
        this.verifyEqual(out_channel, 1);
    
        [~, infos, data] = pspm_load_data(this.data_filename, out_channel);
        sr = data{1}.header.sr;
        data_values = data{1}.data;
        this.verifyEqual( numel(data{1}.data)/ data{1}.header.sr , 25)
        
        % Middle should remain untouched
        idx_1 = round(6*sr):round(19*sr);
        idx_2 = data_values(round(20*sr):end);
        this.verifyFalse(any(isnan(data_values(idx_1))));
    
        % Partially overlapping end: 20 to 30 should remove from 20s to end
        this.verifyTrue(all(isnan(idx_2)));
    
        % Fully outside epoch 40-50 should not cause errors
    
        delete(outside_epoch_file);
        copyfile(this.backup_data_filename, this.data_filename);
    end

    function ContinuousEpochsBeforeFilelength(this)
        % Test epochs that are partly or fully outside the data length
        epochs = [-5, 5; 20, 22;];
        outside_epoch_file = 'test_remove_epochs_outside.mat';
        save(outside_epoch_file, 'epochs');

        options = struct('channel_action', 'replace');
        copyfile(this.backup_data_filename, this.data_filename);

        [sts, out_channel] = pspm_remove_epochs(this.data_filename, 1, outside_epoch_file, options);
        this.verifyEqual(sts, 1);
        this.verifyEqual(out_channel, 1);

        [~, ~, data] = pspm_load_data(this.data_filename, out_channel);
        sr = data{1}.header.sr;
        data_values = data{1}.data;


        % Partially overlapping beginning: -5 to 5 should remove from start to 5s

        idx_1 = round(1*sr):round(5*sr);
        idx_2 = round(20*sr):round(22*sr);

        this.verifyTrue(all(isnan(data_values(idx_1))));
        this.verifyTrue(all(isnan(data_values(idx_2))));

        % Fully outside epoch 40-50 should not cause errors

        delete(outside_epoch_file);
        copyfile(this.backup_data_filename, this.data_filename);
    end


end

methods(TestClassTeardown)
    function cleanup(this)
        % Delete the test files
        if isfile(this.epochs_filename)
            delete(this.epochs_filename);
        end
        if isfile(this.data_filename)
            delete(this.data_filename);
        end
        if isfile(this.backup_data_filename)
            delete(this.backup_data_filename);
        end
        if isfile(this.event_filename)
            delete(this.event_filename);
        end
        if isfile(this.backup_event_filename)
            delete(this.backup_event_filename);
        end
    end
end
end

