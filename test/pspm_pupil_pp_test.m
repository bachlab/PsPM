classdef pspm_pupil_pp_test < pspm_testcase
    % PSPM_PUPIL_PP_TEST
    % unittest class for the pspm_pupil_pp function
    %__________________________________________________________________________
    % PsPM TestEnvironment
    % (C) 2019 Eshref Yozdemir (University of Zurich)

    properties
        raw_input_filename = fullfile('ImportTestData', 'eyelink', 'S114_s2.asc');
        pspm_input_filename = '';
    end

    methods(TestClassSetup)
        function backup(this)
            import = {};
            import{end + 1}.type = 'pupil_r';
            import{end}.eyelink_trackdist = 600;
            import{end}.distance_unit = 'mm';
            import{end + 1}.type = 'pupil_l';
            import{end}.eyelink_trackdist = 600;
            import{end}.distance_unit = 'mm';
            import{end + 1}.type = 'gaze_x_r';
            import{end + 1}.type = 'gaze_y_r';
            import{end + 1}.type = 'gaze_x_l';
            import{end + 1}.type = 'gaze_y_l';
            import{end + 1}.type = 'marker';
            options.overwrite = true;
            this.pspm_input_filename = pspm_import(this.raw_input_filename, 'eyelink', import, options);
            this.pspm_input_filename = this.pspm_input_filename{1};
        end
    end

    methods(Test)
        function invalid_input(this)
            this.verifyWarning(@()pspm_pupil_pp(52), 'ID:invalid_input');
            this.verifyWarning(@()pspm_pupil_pp('abc'), 'ID:nonexistent_file');

            opt.channel = 'gaze_x_l';
            this.verifyWarning(@()pspm_pupil_pp(this.pspm_input_filename, opt), 'ID:invalid_input');

            opt.channel = 'pupil_l';
            opt.channel_combine = 'gaze_y_l';
            this.verifyWarning(@()pspm_pupil_pp(this.pspm_input_filename, opt), 'ID:invalid_input');

            opt.channel_combine = 'pupil_l';
            this.verifyWarning(@()pspm_pupil_pp(this.pspm_input_filename, opt), 'ID:invalid_input');
        end

        function check_if_preprocessed_channel_is_saved(this)
            opt.channel = 'pupil_r';
            [sts, out_channel] = pspm_pupil_pp(this.pspm_input_filename, opt);
            load(this.pspm_input_filename);

            this.verifyEqual(data{out_channel}.header.chantype, 'pupil_r_pp');
        end

        function check_upsampling_rate(this)
            for freq = [500 1000 1500]
                opt.custom_settings.valid.interp_upsamplingFreq = freq;
                opt.channel = 'pupil_r';
                [sts, out_channel] = pspm_pupil_pp(this.pspm_input_filename, opt);
                load(this.pspm_input_filename);

                pupil_chan_indices = find(cell2mat(cellfun(@(x) strcmp(x.header.chantype, 'pupil_r'), data, 'uni', false)));
                pupil_chan = pupil_chan_indices(end);
                sr = data{pupil_chan}.header.sr;
                upsampling_factor = freq / sr;

                this.verifyEqual(numel(data{pupil_chan}.data) * upsampling_factor, numel(data{out_channel}.data));
            end
        end

        function check_channel_combining(this)
            opt.channel = 'pupil_r';
            opt.channel_combine = 'pupil_l';
            [sts, out_channel] = pspm_pupil_pp(this.pspm_input_filename, opt);
            load(this.pspm_input_filename);

            this.verifyEqual(data{out_channel}.header.chantype, 'pupil_lr_pp');
        end

        function check_segments(this)
            opt.channel = 'pupil_r';
            opt.segments{1}.start = 5;
            opt.segments{1}.end = 10;
            opt.segments{1}.name = 'seg1';
            opt.segments{2}.start = 25;
            opt.segments{2}.end = 27;
            opt.segments{2}.name = 'seg2';

            [sts, out_channel] = pspm_pupil_pp(this.pspm_input_filename, opt);
            load(this.pspm_input_filename);

            this.verifyTrue(isfield(data{out_channel}.header, 'segments'));
            this.verifyEqual(data{out_channel}.header.segments{1}.name, 'seg1');
            this.verifyEqual(data{out_channel}.header.segments{2}.name, 'seg2');
        end
    end

    methods(TestClassTeardown)
        function restore(this)
            delete(this.pspm_input_filename);
        end
    end
end
