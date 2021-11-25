function time = pspm_index2time(index, sr, varargin)

% DEFINITION
%   pspm_index2time converts index to time.
% FORMAT
%   time = pspm_index2time(index, sr, varargin)
% ARGUMENTS
%   Input
%     index        an integer
%                  meaning: index / data point
%     sr           a numerical value
%                  meaning: sampling rate / frequency
%   Output
%     time         a decimal
%                  meaning: time; unit: second
%   Optional (varargin)
%      precision   an integer
%                  meaning: how many digits to keep in the output
% PsPM 5.1.2
% (C) 2021 Teddy Chao (WCHN, UCL)
% Supervised by Professor Dominik Bach (WCHN, UCL)

time = index / sr;
if ~isempty(varargin)
  precision = varargin{1};
  time = round(time, precision)
end

end
