function [out] = pspm_cfg_run_pupil_gaze_convert(job)

% $Id$
% $Rev$

channel_action = job.channel_action;
fn = job.datafile{1};

lengths = [ "mm", "cm", "m", "inches" ]


for i=1:numel(job.conversions)
  conversion = job.conversions{i};
  options = struct('channel_action', channel_action);
  if (isfield(conversion, 'degree2sps'))
    % do degree to sps conversion
    [sts, out] = pspm_convert_visangle2sps(fn, options);

  elseif (isfield(conversion, 'distance2sps'))
    args = conversion.distance2sps;
    [sts, out] = pspm_pupil_gaze_distance2sps(fn, args.from, args.height, args.width, args.screen_distance, options);

  elseif (isfield(conversion, 'distance2degree'))
    args = conversion.distance2degree;
    [ sts, out ] = pspm_pupil_gaze_distance2degree(fn, args.from, args.height, args.width, args.screen_distance, options);
  end
end

out = 1;
