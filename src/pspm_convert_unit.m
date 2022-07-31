function [sts, converted] = pspm_convert_unit(data, from, to)
% ● Description
%   pspm_convert_unit is a function to convert between different units
%   currently only length units are possible.
% ● Format
%   [sts, converted] = pspm_convert_unit(data, from, to)
% ● Arguments
%   data: The data which should be converted. Must be a numeric
%         array of any shape.
%   from: Unit of the input vector.
%         Valid units are currently mm, cm, dm, m, km, in, inches
%     to: Unit of the output vector.
%         Valid units are currently mm, cm, dm, m, km, in, inches
% ● Introduced In
%   PsPM 4.0
% ● Written By
%   (C) 2018 Tobias Moser (University of Zurich)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
converted = [];

% define conversion settings
converter = struct('length', ...
  struct(...
  'value', {'mm', 'cm', 'dm', 'm', 'km', 'in', 'inches'}, ...
  'factor', {10^-3, 10^-2, 10^-1, 1, 10^3, 2.54e-2, 2.54e-2}...
  ));

% input checks
% -----------------------------------------------------------------------------
if ~isnumeric(data)
  warning('ID:invalid_input', 'Data is not numeric.');
  return;
elseif ~(isstr(from) && isstr(to) && all(ismember({from, to}, {converter.length.value})))
  valid_units_str = join({converter.length.value}, ', ');
  valid_units_str = valid_units_str{1};
  warning('ID:invalid_input', 'Both units must be string and must be one of %s.\n', valid_units_str);
  return;
end

[~, from_idx] = ismember(from, {converter.length.value});
[~, to_idx] = ismember(to, {converter.length.value});

from_fact = converter.length(from_idx).factor;
to_fact = converter.length(to_idx).factor;

converted = data*from_fact/to_fact;
sts = 1;
end