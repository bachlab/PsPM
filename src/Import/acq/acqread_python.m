function [sts, header, data] = acqread_python(filename)
% ● Description
%   acqread_python read data from acq files by calling bioread package.
% ● Format
%   [sts, data] = acqread_python(filename)
% ● Arguments
%   filename: the ACQ data file to import
%     import: the import struct of importing settings
% ● History
%   Introduced in PsPM 7.0
%   Written in May 2024 by Madni Abdul Wahab (Uni Bonn) and Teddy

global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
%% Initialise python
if ~isfield(settings, 'python_path')
  psts = pspm_check_python;
else
  psts = pspm_check_python(settings.python_path);
end
%% Set the Python environment and the filename
py_filename = py.str(filename);
acq_data = py.bioread.read(py_filename); % Load the data using Bioread
raw = struct();
%% Iterate through each channel
for idx = 1:length(acq_data.channels)
  chan_raw = acq_data.channels{idx};
  % Convert Python dir() list to MATLAB cell array
  attrs = cell(py.dir(chan_raw));
  % Convert all attributes to strings to ensure compatibility with startsWith
  attrs = cellfun(@char, attrs, 'UniformOutput', false);
  % Manually filter out private attributes (those starting with '_') in MATLAB
  filtered_attrs = attrs(~startsWith(attrs, '_'));
  % Iterate over attributes and fetch their values
  for attr_name = filtered_attrs
    % Python getattr to get attribute value
    attr_value = py.getattr(chan_raw, attr_name{1});
    % Try converting Python data types to MATLAB data types
    try
      if isa(attr_value, 'py.numpy.ndarray')
        % Special handling for ndarrays
        matlab_value = double(py.array.array('d', py.numpy.nditer(attr_value)));
      elseif isa(attr_value, 'py.list')
        matlab_value = cell(attr_value);
      elseif isa(attr_value, 'py.dict')
        matlab_value = struct(attr_value);
      elseif isa(attr_value, 'py.str')
        matlab_value = char(attr_value);
      elseif isa(attr_value, 'py.int') || isa(attr_value, 'py.float')
        matlab_value = double(attr_value);
      else
        matlab_value = attr_value; % If not a recognizable type, leave as is
      end
    catch
      matlab_value = []; % If conversion fails, set as empty
    end
    raw.(char(attr_name{1})){idx} = matlab_value;
  end
end
data = raw.data;
header = struct();
header.dSampleTime = unique([raw.samples_per_second{:}])/1000;
% this was in "s", now converted to "ms" to be in line with conventional acq_read
header.szCommentText = raw.name;
header.szUnitsText = raw.units;
header.nVarSampleDivider = [raw.frequency_divider{:}];
header.dAmplScale = [raw.raw_scale_factor{:}];
header.dAmplOffset = [raw.raw_offset{:}];
sts = 1;
return
