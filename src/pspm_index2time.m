function time = pspm_index2time(index, sr, varargin)

% pspm_index2time converts index to time.
% FORMAT
%   time = pspm_index2time(index, sr, varargin)
% VARIABLES
%   index           an integer
%                   meaning: index / data point
%   time            a decimal
%                   meaning: time
%   sr              a numerical value
%                   meaning: sampling rate / frequency
%   varargin
%     precision   	an integer
%                   meaning: how many digits to keep in the output
% PsPM 5.1.2
% (C) 2021 Teddy Chao (WCHN, UCL)

time = index / sr;
if ~isempty(varargin)
	precision = varargin{1};
	time = round(time, precision)
end

end