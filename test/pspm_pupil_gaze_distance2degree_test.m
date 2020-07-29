classdef pspm_pupil_gaze_distance2degree_test < matlab.unittest.TestCase
% pspm_pupil_gaze_distance2degree_test 
% unittest class for the pspm_pupil_gaze_distance2degree_test function


    properties
        raw_input_filename = fullfile('../', 'ImportTestData', 'eyelink', 'S114_s2.asc');
        fn = '';
    end

    properties (TestParameter)
        channel_action = { 'add', 'replace' };
        from = { 'pixel', 'mm', 'inches' };
    end

    methods
        function len = get_gaze_and_unit(this, data, unit)
            len = find(cellfun(@(c) strcmp(c.header.units, unit) && ~isempty(regexp(c.header.chantype, 'gaze_[x|y]_[r|l]')), data));
        end;
    end

    methods(TestMethodSetup)
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
            this.fn = pspm_import(this.raw_input_filename, 'eyelink', import, options);
            this.fn = this.fn{1};
        end
    end
    

    methods (Test)

        function validations(this)
          this.verifyWarning(@() pspm_pupil_gaze_distance2degree(this.fn, "not_a_unit", 111, 222, 333),  'ID:invalid_input');
          this.verifyWarning(@() pspm_pupil_gaze_distance2degree(this.fn, "pixel", 'not_a_number', 222, 333),  'ID:invalid_input');
          this.verifyWarning(@() pspm_pupil_gaze_distance2degree(this.fn, "not_a_unit", 111, 'not_a_number', 333),  'ID:invalid_input');
          this.verifyWarning(@() pspm_pupil_gaze_distance2degree(this.fn, "not_a_unit", 111, 222, 'not_a_number'),  'ID:invalid_input');
        end

        function from_pixel(this, from, channel_action)
            % test with width 200mm, height 100mm and 2 pixel per mm
            load(this.fn);
            width = 323;
            height = 232;
            distance = 600;

            if (~strcmp(from, 'pixel'));
              pspm_convert_pixel2unit(this.fn, 0, from, width, height, distance);
              load(this.fn);
              this.verifyLength(this.get_gaze_and_unit(data, from), 4);
            end;

            data_length = length(data);
            this.verifyLength(this.get_gaze_and_unit(data, 'degree'), 0);

            [sts, out_channel] = pspm_pupil_gaze_distance2degree(...
              this.fn, from, width, height, distance, struct('channel_action', channel_action));
            load(this.fn);
            
            this.verifyEqual(length(data), data_length + 4);
            data_length = length(data);

            this.verifyLength(this.get_gaze_and_unit(data, 'degree'), 4);
            this.verifyEqual(sts, 1);

            [sts, out_channel] = pspm_pupil_gaze_distance2degree(...
              this.fn, from, width, height, distance, struct('channel_action', channel_action));
            load(this.fn);

            if (strcmp(channel_action, 'add'));
              data_length = data_length + 4;
            end;

            this.verifyEqual(length(data), data_length);
            this.verifyEqual(sts, 1);

        end
      
    end

end
