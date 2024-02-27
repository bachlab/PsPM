function index = pspm_time2index(time, sr, varargin)
% ● Description
%   pspm_time2index converts time stamps in seconds to a data index.
% ● Format
%   index = pspm_time2index(time, sr, varargin)
% ● Arguments
%           time: [vector or matrix] time stamps in second.
%             sr: [numeric] sampling rate or frequency
%   ┌───varargin: optional variables
%   └data_length: [integer] the length of data, by which the length of data
%                 points should not exceed
% ● Output
%          index: [integer] index or data point
% ● History
%   Introduced in PsPM 5.1.2
%   Written in 2021 by Teddy Chao (UCL)

index = round(time * sr);
index(index == 0) = 1;

if ~isempty(varargin)
  data_length = varargin{1};
  flag = index > ones(size(index)) * data_length;
  if sum(sum(flag)) > 0
    index(flag==1) = data_length;
  end
end
return
