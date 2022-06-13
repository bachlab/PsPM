function [sts, outchannel] = pspm_eye_pp(fn,options)
% ● Definition
%   pspm_eye_pp is a unified function for processing eye signals. Accepted
%   eye signals include pupil signals and gaze signals.
% ● Format
%   [sts, outchannel] = pspm_eye_pp(fn)
%   [sts, outchannel] = pspm_eye_pp(fn, options)

%% 1 Input checks
if ~ismember(options.channel, {'pupil', 'gaze'})
	warning('ID:invalid_input', 'eye_pp can only process pupil or gaze');
	return
end

%% 2 Processing
switch options.channel
  case 'pupil'
    [sts, outchannel] = pspm_pupil_pp(fn, options);
  case 'gaze'
    [sts, outchannel] = pspm_gaze_pp(fn, options);
end

end