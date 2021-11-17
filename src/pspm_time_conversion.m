function output = pspm_time_conversion(input, options)

% pspm_time_conversion converts time-related variables.
% FORMAT
%   output = pspm_time_conversion(input, options)
% VARIABLES
%   input         either time or data point
%   output        either data point or time
%   options
%     sr          a numerical value
%                 meaning: sampling rate/frequency
%     method      a string, accepted values include 'time2dp', 'dp2time'.
%                 meaning: conversion method, like dp2time indicating data points to time
%     data_length (optional) a numerical value
%                 meaning: the length of data, by which data points should not exceed
% PsPM 5.1.2
% (C) 2021 Teddy Chao (WCHN, UCL)

%% Validating inputs
if ~isfield(options, 'sr')
  warning('ID:invalid_input', 'Option sampling rate (sr) must be a numerical value');
end
if ~ismember(options.method, {'time2dp', 'dp2time'})
  warning('ID:invalid_input', 'Option method must be either ''time2dp'' or ''dp2time''');
  return
end
if ~isfield(options, 'data_length')
  options.data_length = 0;
end

%% Conversion
switch options.method
  case time2dp
    output = round(input * options.sr);
    if output == 0
      output = 1;
    end
    if output > options.data_length && options.data_length ~= 0
      output = options.data_length;
    end
  case dp2time
    output = input / options.sr;
end

end