classdef pspm_interpolate_test < matlab.unittest.TestCase
    % ● Description
    % unittest class for the pspm_interpolate function
    % testEnvironment for PsPM version 6.0
    % ● Authorship
    % (C) 2015 Tobias Moser (University of Zurich)
    %			2022 Teddy Chao (UCL)
    properties
        datafile = 'interpolate_test';
        testdata = {};
    end
    properties (TestParameter)
        % interpolation test
        interp_method = {'linear', 'pchip', 'nearest', 'spline', 'previous', 'next'};
        nan_method = {'start', 'center', 'end'};
        extrap = {true, false};
        % valid input test
        amount = {1, 6};
        datatype = {'file', 'inline'};
        chans = { ...
            {{'scr'}, []}, ...
            {{'scr', 'hb', 'scr'},[]}, ... % hb channels shouldn't be interpolated (events)
            {{'scr', 'scr', 'scr'}, [1,3]} ... % all channels except first should be interpolated
            };
        newfile = {true, false};
        replace_channels = {true, false};
    end
    methods
        function [data, opt_chans] = generate_data(this, datatype, amount, nan_method, chans, extrap)
            opt_chans = cell(1,amount);
            if strcmpi(datatype, 'all')
                expand = {1, 2, 3};
                if amount < numel(expand)
                    expand = {1:amount};
                end
            else
                expand = {find(strcmpi(datatype, this.datatype))};
            end
            data = repmat(expand, 1, ceil(amount/numel(expand)));
            % force cell
            if numel(data) == 1 && ~iscell(data)
                data = {data};
            end
            for i = 1:amount
                % generate data
                if strcmpi(this.datatype{data{i}}, 'inline')
                    % inline is always just one channel
                    c{1}.chantype = 'scr';
                    if amount > 1
                        opt_chans{i} = {};
                    end
                else
                    % not inline is with chans option
                    c = cell(1,numel(chans{1}));
                    for j=1:numel(chans{1})
                        c{j}.chantype = chans{1}{j};
                    end
                    opt_chans{i} = chans{2};
                end
                d = pspm_testdata_gen(c, 10);
                % put nans
                for j=1:numel(d.data)
                    d.data{j}.data = this.put_nan(d.data{j}.data, nan_method, extrap);
                end
                if strcmpi(this.datatype{data{i}}, 'file')
                    % find filename
                    fn = pspm_find_free_fn(this.datafile, '.mat');
                    % save data
                    pspm_load_data(fn, d);
                    data{i} = fn;
                elseif strcmpi(this.datatype{data{i}}, 'struct')
                    data{i} = d;
                elseif strcmpi(this.datatype{data{i}}, 'inline')
                    data{i} = d.data{1}.data;
                end
            end
            this.testdata{end+1} = data;
        end
        function outdata = put_nan(~, indata, method, extrap)
            middle = floor(numel(indata)/2);
            % if extrapolation is given we can delete to the end and
            % beginning of the file; otherwise not
            if extrap
                offset = 0;
            else
                offset = 1;
            end
            mdl = middle-1-offset;
            switch method
                case 'start'
                    s = 1+offset;
                    e = 1+offset+round(rand * mdl);
                case 'center'
                    s = 1+ceil(rand * mdl);
                    e = floor(rand * mdl) + middle;
                case 'end'
                    s = ceil(rand * mdl) + middle;
                    e = numel(indata) - offset;
            end
            outdata = indata;
            outdata(s:e) = NaN;
        end
        function verify_nan_free(this, data, channels)
            if isnumeric(data)
                % only one channel to interpolate
                this.verifyTrue(~any(isnan(data)));
            else
                [~, ~, d] = pspm_load_data(data, 0);
                for i = 1:numel(d)
                    % only test non-event channels
                    if ~strcmpi(d{i}.header.units, 'events')
                        if (isnumeric(channels) && ismember(i, channels)) || ...
                                (ischar(channels) && strcmpi(channels, 'all'))
                            this.verifyTrue(~any(isnan(d{i}.data)));
                        else
                            % data should contain nans because
                            % channels is not empty and i is not member of
                            % channels -> should not be interpolated
                            %
                            % only in this case where data is always
                            % generated with NaNs inside (expect events
                            % channels)
                            this.verifyTrue(any(isnan(d{i}.data)));
                        end
                    end
                end
            end
        end
    end
    methods (TestMethodTeardown)
        function cleanup_data(this)
            data = this.testdata;
            % if datafield is a file, delete it
            for i = 1:numel(data)
                for j = 1:numel(data{i})
                    if ischar(data{i}{j}) && exist(data{i}{j}, 'file')
                        delete(data{i}{j});
                    end
                end
            end
            this.testdata = {};
        end
    end
    methods (Test)
        function invalid_input(this)
            c{1}.chantype = 'scr';
            c{2}.chantype = 'hb';
            fn = pspm_find_free_fn(this.datafile, '.mat');
            pspm_testdata_gen(c, 10, fn);
            valid_data = fn;
            % no input
            this.verifyWarning(@() pspm_interpolate(), 'ID:missing_data');
            % data ist not (char, struct, numeric)
            invalid_data = {{}};
            this.verifyWarning(@() pspm_interpolate(invalid_data), 'ID:invalid_input');
            % empty data
            invalid_data = [];
            this.verifyWarning(@() pspm_interpolate(invalid_data), 'ID:missing_data');
            % invalid filename
            invalid_data = 'file_does_not_exist';
            this.verifyWarning(@() pspm_interpolate(invalid_data, 1), 'ID:nonexistent_file');
            % invalid amount of channels
            channel = numel(valid_data)+1;
            this.verifyWarning(@() pspm_interpolate(valid_data, channel), 'ID:invalid_input');
            % invalid channel type
            channel = 'ab';
            this.verifyWarning(@() pspm_interpolate(valid_data, channel), 'ID:invalid_chantype');
            % invalid interpolation method
            options = struct('method', 'invalid_method');
            this.verifyWarning(@() pspm_interpolate(valid_data, 'all', options), 'ID:invalid_input');
            % invalid newfile
            options = struct('newfile', 'bla');
            this.verifyWarning(@() pspm_interpolate(valid_data, 'all', options), 'ID:invalid_input');
            % invalid extrapolate
            options = struct('extrapolate', 'bla');
            this.verifyWarning(@() pspm_interpolate(valid_data, 'all', options), 'ID:invalid_input');
            % invalid channel_action
            options = struct('channel_action', 'bla');
            this.verifyWarning(@() pspm_interpolate(valid_data, 'all', options), 'ID:invalid_input');
            % try to interpolate an events channel
            this.verifyWarning(@() pspm_interpolate(valid_data, 2), 'ID:unexpected_channeltype');
            % try to interpolate with nan from beginning; without
            % extrapolation
            fn1 = pspm_find_free_fn(this.datafile, '.mat');
            c{1}.chantype = 'scr';
            invalid_data = pspm_testdata_gen(c, 10);
            invalid_data.data{1}.data(1) = NaN;
            sts = pspm_load_data(fn1, invalid_data);
            fn2 = pspm_find_free_fn(this.datafile, '.mat');
            invalid_data.data{1}.data(1) = 0;
            invalid_data.data{1}.data(end) = NaN;
            sts = pspm_load_data(fn2, invalid_data);
            this.verifyWarning(@() pspm_interpolate(fn1, 1), 'ID:option_disabled');
            options = struct('extrapolate', true, 'method', 'previous');
            this.verifyWarning(@() pspm_interpolate(fn1, 1, options), 'ID:out_of_range');
            % finalise
            options = struct('extrapolate', true, 'method', 'next');
            this.verifyWarning(@() pspm_interpolate(fn2, 1, options), 'ID:out_of_range');
            % clear files
            delete(fn);
            delete(fn1);
            delete(fn2);
        end
        function test_datatypes(this, datatype, amount, chans)
            % generate data
            [data, opt_chans] = generate_data(this, datatype, amount, 'center', chans, false);
            % define options
            channel = 'all';
            options.method = 'linear';
            options.extrapolate = false;
            % call function
            if strcmpi(datatype, 'file')
                [sts, outdata] = this.verifyWarningFree(@() pspm_interpolate(data{1}, channel, options));
            elseif strcmpi(datatype, 'inline')
                [sts, outdata] = this.verifyWarningFree(@() pspm_interpolate(data{1}, options));
            end
            %% test if function works as expected
            % sts should be 1
            this.verifyEqual(sts, 1);
            % output data should have same size as input data
            if strcmpi(datatype, 'inline')
                this.verifyEqual(size(data{1}), size(outdata));
            end
            % but data shouldn't be the same
            this.verifyNotEqual(data{1}, outdata);
            % test for nans:
            % * interpolated channels should contain no more nans
            % * not interpolated channels (specified by options.channel)
            %   should still contain nans
            if iscell(outdata)
                for i = 1:numel(outdata)
                    if strcmpi(datatype, 'file')
                        % will return new channels which have been added to
                        % the existing file so we need to get the
                        % filenames out of the generated data
                        check_data = data{i};
                        check_chans = outdata{i};
                    else
                        check_data = outdata{i};
                        if iscell(options.channel) && numel(options.channel) > 0
                            check_chans = options.channel{i};
                        else
                            check_chans = {};
                        end
                    end
                    % verify
                    this.verify_nan_free(check_data, check_chans);
                end
            else
                this.verify_nan_free(outdata, channel);
            end
            % delete output
            if strcmpi(datatype, 'file')
                delete(outdata);
            end
        end
        function test_interpolation_variations(this, interp_method, extrap, nan_method)
            % generate data
            [data, opt_chans] = generate_data(this, 'inline', 1, nan_method, {{'scr'}, []}, extrap);
            % define options
            channel = opt_chans;
            options.method = interp_method;
            options.extrapolate = extrap;
            if extrap && (...
                    (strcmpi(nan_method, 'start') && strcmpi(interp_method, 'previous')) || ...
                    (strcmpi(nan_method, 'end') && strcmpi(interp_method, 'next')))
                % this makes no sense -> should give warning
                [~, ~] = this.verifyWarning(@() pspm_interpolate(data{1}, options), 'ID:out_of_range');
            else
                % call function
                [sts, outdata] = this.verifyWarningFree(@() pspm_interpolate(data{1}, options));
                % sts should be 1
                this.verifyEqual(sts, 1);
                % output data should have same size as input data
                this.verifyEqual(size(data{1}), size(outdata));
                % but data shouldn't be the same
                this.verifyNotEqual(data{1}, outdata);
                % test for nans:
                this.verify_nan_free(outdata);
            end
        end
        function test_no_nan(this)
            %% try to interpolate without nans
            % generate data
            c{1}.chantype = 'scr';
            data = pspm_testdata_gen(c, 10);
            data = data.data{1}.data;
            % interpolate
            [sts, outdata] = this.verifyWarningFree(@() pspm_interpolate(data));
            % sts should be 1
            this.verifyEqual(sts, 1);
            % output data should have same size as input data
            this.verifyEqual(size(data), size(outdata));
            % data should be the same (nothing to interpolate)
            this.verifyEqual(data, outdata);
            % because load_data will add "flank" property to the original
            % header, currently only data is verified here.
            % test for nans
            this.verify_nan_free(outdata, {});
        end
        function test_write(this, newfile)
            % test whether data is added to a new channel or a new file is
            % created
            c_info = {{'scr', 'scr', 'scr'}, [1,3]};
            % generate data
            [data, opt_chans] = generate_data(this, 'file', 2, 'center', c_info, false);
            data = data{1};
            % define options
            options.method = 'linear';
            options.extrapolate = false;
            % call function
            if newfile
                [sts, outdata] = this.verifyWarningFree(@() pspm_interpolate(data, 'all', options));
            else
                [sts, outdata] = this.verifyWarningFree(@() pspm_interpolate(data, 1, options));
            end
            % sts should be 1
            this.verifyEqual(sts, 1);
            if newfile
                % data shouldn't be the same
                this.verifyNotEqual(data, outdata);
                % check if file exists and delete
                file_exist = exist(outdata, 'file');
                this.verifyTrue(file_exist > 0);
                [~, ~, olddata] = pspm_load_data(data);
                [~, ~, newdata] = pspm_load_data(outdata);
                this.verifyEqual(size(olddata), size(newdata));
                this.verify_nan_free(outdata, 1:3);
                if file_exist
                    delete(outdata);
                end
            else
                % data should be the same
                this.verifyEqual(data, outdata);
                % check if last channels match the size of the announced channels
                % verify nan is already done by datatype
                [sts, infos, data] = pspm_load_data(outdata);
                this.verifyEqual(numel(c_info{1}) + 1, numel(data));
            end
        end
        function test_overwrite(this)
            % generate data
            [data, ~] = generate_data(this, 'file', 2, 'center', ...
                {{'scr', 'scr', 'scr'}, [1,2,3]} , false);
            data = data{1};
            % create file beforehand
            fclose(fopen(['i', data], 'w'));
            % no overwriting allowed
            options.overwrite = 0;
            [sts, ~] = this.verifyWarning(@() pspm_interpolate(data, 'all', options),'ID:data_loss');
            % overwriting allowed
            options.overwrite = 1;
            [sts, ~] = this.verifyWarningFree(@() pspm_interpolate(data, 'all', options));
            this.verifyEqual(sts, 1); % sts should be 1
            % test that existing data was properly overwritten, i.e. file
            % is PsPM file
            this.verifyWarningFree(@() pspm_load_data(['i', data], 0));
            if exist(['i', data], 'file')
                delete(['i', data]);
            end
        end
    end
end
