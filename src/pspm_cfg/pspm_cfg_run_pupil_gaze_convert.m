function [out] = pspm_cfg_run_pupil_gaze_convert(job)

% $Id$
% $Rev$

channel_action = job.channel_action;
fn = job.datafile{1};

lengths = [ 'mm', 'cm', 'm', 'inches' ]

for i=1:numel(job.conversion)
    options = struct();
    options.channel_action = channel_action;
    chan = job.conversion(i).channel;
    from = job.conversion(i).from.name;
    to = job.conversion(i).to.name;
    % from pixel
    if strcmp(from, 'pixel')
      % to anything but scanpath speed
      if ~strcmp(to, 'sps')
        pspm_convert_pixel2unit(fn, chan, to, width, height,distance, options);
      else
        % for conversion to scanpath speed first convert to degrees then scanpath speed
        pspm_convert_pixel2unit(fn, chan, 'degree', width, height,distance, options);
        options.eyes = job.conversion(i).eyes;
        % if channel_action was add, the previous conversion would have created a new channel
        % so here where change to replace to overwrite the temporary degree channel
        options.channel_action = 'replace'
        pspm_convert_visangle2sps(fn,options);
      end

    elseif ismember(from, lengths)
      % length to length
        % TODO pull data from fn and chan
      if ismember(to, lengths)
        [sts, out ] = pspm_convert_unit(data, from, to)

      elseif strcmp(to, 'degree')
        [sts, out ] = pspm_convert_unit(data, from, 'mm')

        temp_channel.data = out;
        temp_channel.header.sr = data{gx}.header.sr;
        temp_channel.header.units = to;    
        [lsts, outinfo] = pspm_write_channel(fn, dist_channel, 'add');

        % write to file with channel action
        options.channel_action = 'replace';
        [sts, out] = pspm_compute_visual_angle(fn,0, ...
          width, height, distance, unit_h_w_d,options);

      elseif strcmp(to, 'sps')
        [sts, out ] = pspm_convert_unit(data, from, 'mm')
        % write to file with channel action

        options.channel_action = 'replace';
        [sts, out] = pspm_compute_visual_angle(fn,outinfo.channel, ...
          width, height, distance,unit_h_w_d,options);

        options.chans = chan;
        options.eyes = job.conversion(i).mode.visangle2sps.eyes;
        [sts, out] = pspm_convert_visangle2sps(fn,options);
      end

    elseif strcmp(from, 'degree')
      options.chans = chan;
      [sts, out] = pspm_convert_visangle2sps(fn,options);
    end

end

out = 1;
