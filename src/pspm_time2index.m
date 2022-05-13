function index = pspm_time2index(time, sr, varargin)
  % ● Description
% pspm_time2index converts time to index.
% FORMAT
% index = pspm_time2index(time, sr, varargin)
% ARGUMENTS
% Input
%   time            a decimal
%                   meaning: time; unit: second
%   sr              a numerical value
%                   meaning: sampling rate / frequency
%   varargin
%     data_length   an integer
%                   meaning: the length of data, by which data points should not exceed
% Output
%   index           an integer
%                   meaning: index / data point
% PsPM 5.1.2
% contributed by: 
% 2021 Teddy Chao (WCHN, UCL)

if ~isempty(varargin)
  data_length = varargin{1};
end
index = round(time * sr);
index(index == 0) = 1;
if exist('data_length', 'var')
  flag = index > ones(size(index)) * data_length;
  if sum(sum(flag)) > 0
    index(flag==1) = data_length;
  end
end