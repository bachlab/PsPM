function eye = pspm_get_eye(chantype)

% DEFINITION
% pspm_get_eye detect the eye location from an input channel type
%
%	FORMAT
%	eye = pspm_get_eye(chantype)
%
% ARGUMENTS
%   Input
%     chantype  a string that contains the eye location
%   Output
%     eye    		a character
%
% PsPM (version 5.1.2)
% (C) 2021 Teddy Chao (WCHN, UCL)
% Supervised by Professor Dominik Bach (WCHN, UCL)

eye = 'unknown';

for eye_attempt = ['l', 'r', 'c']
	if contains(chantype, ['_', eye_attempt, '_'])
		eye = eye_attempt;
	elseif chantype(length(chantype)-1:length(chantype)) == ['_', eye_attempt]
		eye = eye_attempt;
	end
end

if strcmp(eye, 'unknown')
	warning('ID:invalid_input', 'chantype does not contain a valid eye');
	return
end

end
