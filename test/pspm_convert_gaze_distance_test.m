classdef pspm_convert_gaze_distance_test < matlab.unittest.TestCase
% pspm_convert_gaze_distance_test 
% unittest class for the pspm_convert_gaze_distance_test function


    properties
        raw_input_filename = fullfile('ImportTestData', 'eyelink', 'S114_s2.asc');
        fn = '';
    end

    properties (TestParameter)
        channel_action = { 'add', 'replace' };
        from = { 'pixel', 'mm', 'inches' };
        target = { 'degree', 'sps' };
    end

    methods
        % get the gaze data channels for a specific unit
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

        function validations(this, target)
          this.verifyWarningFree(@() pspm_convert_gaze_distance(this.fn, target, 'pixel', 111, 222, 333));
          this.verifyWarning(@() pspm_convert_gaze_distance(this.fn, target, "not_a_unit", 111, 222, 333),  'ID:invalid_input:from');
          this.verifyWarning(@() pspm_convert_gaze_distance(this.fn, target, "pixel", 'not_a_number', 222, 333),  'ID:invalid_input:width');
          this.verifyWarning(@() pspm_convert_gaze_distance(this.fn, target, "pixel", 111, 'not_a_number', 333),  'ID:invalid_input:height');
          this.verifyWarning(@() pspm_convert_gaze_distance(this.fn, target, "pixel", 111, 222, 'not_a_number'),  'ID:invalid_input:distance');
          this.verifyWarning(@() pspm_convert_gaze_distance(this.fn, 'invalid_conversion', 'pixel', 111, 222, 333), 'ID:invalid_input:target');
        end


        function conversion(this, target, from, channel_action)
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
            if strcmp(target, 'degree')
              this.verifyLength(this.get_gaze_and_unit(data, 'degree'), 0);
            else
              this.verifyLength(find(cellfun(@(c) strcmp(c.header.chantype, 'sps_l'), data)), 0);
              this.verifyLength(find(cellfun(@(c) strcmp(c.header.chantype, 'sps_r'), data)), 0);
            end

            [sts, out_channel] = this.verifyWarningFree(@() pspm_convert_gaze_distance(...
              this.fn, target, from, width, height, distance, struct('channel_action', channel_action)));
            load(this.fn);
            this.verifyTrue(length(out_channel.channel) > 0);

            extra = 2;
            if strcmp(target, 'degree')
              extra = 4;
            end

            this.verifyLength(data, data_length + extra);
            data_length = length(data);

            if strcmp(target, 'degree')
              this.verifyLength(this.get_gaze_and_unit(data, 'degree'), 4);
            else
              this.verifyLength(find(cellfun(@(c) strcmp(c.header.chantype, 'sps_l'), data)), 1);
              this.verifyLength(find(cellfun(@(c) strcmp(c.header.chantype, 'sps_r'), data)), 1);
            end

            [sts, out_channel] = this.verifyWarningFree(@() pspm_convert_gaze_distance(...
              this.fn, target, from, width, height, distance, struct('channel_action', channel_action)));
            load(this.fn);

            extra = 0;
            if (strcmp(channel_action, 'add'));
              if strcmp(target, 'degree') 
                extra = extra + 4;
              else
                extra = extra + 2;
              end
            end;

            this.verifyLength(data, data_length + extra);
            this.verifyEqual(sts, 1);

        end
    end

end