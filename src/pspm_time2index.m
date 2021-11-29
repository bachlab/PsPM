function index = pspm_time2index(time, sr, varargin)

% DEFINITION
%   pspm_time2index converts time to index.
% FORMAT
%   index = pspm_time_conversion(time, sr, varargin)
% ARGUMENTS
%   Input
%     time            a numerical value
%                     meaning: time; unit: second
%     sr              a numerical value
%                     meaning: sampling rate / frequency
%     varargin
%       duration      a numerical value
%                     meaning: the duration of the interval, default as time
%       indicator     a character, either 't' or 'i'
%                     meaning: indicating the type of duration
%                     if 't', the duration is given as time, which can be a decimal
%                     if 'i', the duration is given as index, which must be an integer
%   Output
%     index           an integer
%                     meaning: index / data point
% PsPM 5.1.2
% (C) 2021 Teddy Chao (WCHN, UCL)
% Supervised by Professor Dominik Bach (WCHN, UCL)

if ~isempty(varargin)
  switch length(varargin)
  case 1
  data_length = round(varargin{1} * sr);
  case 2
    switch varargin{2}
    case 't'
      data_length = round(varargin{1} * sr);
    case 'i'
      data_length = varargin{1};
    end
  end
end
index = round(time * sr);
if index == 0
  index = 1;
end
if exist('data_length', 'var')
  flag = index > ones(size(index)) * data_length;
  if sum(sum(flag))>0
    index(flag==1) = data_length;
  end
end
end
