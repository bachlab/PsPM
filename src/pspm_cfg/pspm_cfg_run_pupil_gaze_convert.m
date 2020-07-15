function [out] = pspm_cfg_run_pupil_gaze_convert(job)

% $Id$
% $Rev$

channel_action = job.channel_action;
fn = job.datafile{1};

lengths = [ "mm", "cm", "m", "inches" ]

for i=1:numel(job.conversion)
    options = struct();
    options.channel_action = channel_action;
    width = job.conversion(i).width;
    height = job.conversion(i).height;
    distance = job.conversion(i).distance;
    chan = job.conversion(i).channel;
    from = job.conversion(i).from;
    job.conversion(i).to
    to = job.conversion(i).to;
    % from pixel
    if strcmp(from, 'pixel')
      % to anything but scanpath speed
      if ~strcmp(to, 'sps')
        pspm_convert_pixel2unit(fn, chan, to, width, height,distance, options);
      else
        % for conversion to scanpath speed first convert to degrees then scanpath speed
        pspm_convert_pixel2unit(fn, chan, 'degree', width, height,distance, options);
        % if channel_action was add, the previous conversion would have created a new channel
        % so here where change to replace to overwrite the temporary degree channel
        options.channel_action = 'replace'
        pspm_convert_visangle2sps(fn,options);
      end

    elseif ismember(from, lengths)
      % length to length
        % TODO pull data from fn and chan
      [lsts, infos, data] = pspm_load_data(fn,chan);
      data = data{1};

      if ismember(to, lengths)
        [sts, out ] = pspm_convert_unit(data.data, from, to);
        temp_channel = data;
        temp_channel.data = out;
        temp_channel.header.units = to;    
        [lsts, outinfo] = pspm_write_channel(fn, temp_channel, 'add');

      elseif strcmp(to, 'degree')
        % visual angle is calculated using mm so first convert to mm
        if (from ~= 'mm')
          [sts, out ] = pspm_convert_unit(data.data, from, 'mm')
          temp_channel = data;
          temp_channel.data = out;
          temp_channel.header.units = "mm";
          [lsts, outinfo] = pspm_write_channel(fn, temp_channel, 'add');
        end

        % write to file with channel action
        options.channel_action = 'replace';
        [sts, out] = pspm_compute_visual_angle(fn,0, ...
          width, height, distance, 'mm',options);

      elseif strcmp(to, 'sps')
        if (from ~= 'mm')
          [sts, out ] = pspm_convert_unit(data.data, from, 'mm')
          temp_channel = data;
          temp_channel.data = out;
          temp_channel.header.units = "mm";
          [lsts, outinfo] = pspm_write_channel(fn, temp_channel, 'add');
        end
        % write to file with channel action

        options.channel_action = 'replace';
        [sts, out] = pspm_compute_visual_angle(fn,0, ...
          width, height, distance,'mm',options);

        options.chans = chan;
        [sts, out] = pspm_convert_visangle2sps(fn,options);
      end

    elseif strcmp(from, 'degree')
      options.chans = chan;
      [sts, out] = pspm_convert_visangle2sps(fn,options);
    end

end

out = 1;
