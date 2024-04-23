function index = pspm_time2index(time, sr, varargin)
% ● Description
%   pspm_time2index converts time stamps and durations in seconds or markers 
%   to a sample index.
% ● Format (optional arguments in []; all arguments up the last specified
%           one need to be specified)
%   index = pspm_time2index(time, sr [, data_length, zero_permitted, events])
% ● Arguments
%           time: [vector or matrix] time stamps in second.
%             sr: [numeric] sampling rate or frequency
%    data_length: [integer] the length of data, which the index should
%                 should not exceed
%  zero_permitted: [0/1] whether zero is permitted (set to 0 for index and
%                  to 1 for durations; default 0)
%          events: vector of timestamps from a marker channel, will be considered if
%                  given as input
% ● Output
%          index: [integer] index or data point
% ● History
%   Introduced in PsPM 5.1.2
%   Written in 2021 by Teddy Chao (UCL)
%   Refactored in 2024 by Dominik Bach (Uni Bonn)

if nargin < 3
    data_length = inf;
else
    data_length = varargin{1};
end

if nargin < 4
    zero_permitted = 0;
else 
    zero_permitted = 1;
end

if nargin > 4
    events = varargin{3};
    time = events(time);
end

% 1. 'round' can sometimes result in non-integer values
% 2. The first sample of the file corresponds to index 1 and time 0
index = double(int64(round(time * sr))) + 1; 

if zero_permitted < 1
    index(index == 0) = 1;
end

flag = index > ones(size(index)) * data_length;
if any(flag(:) > 0)
    index(flag==1) = data_length;
end
