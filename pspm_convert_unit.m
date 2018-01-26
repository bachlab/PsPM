function [sts, converted] = pspm_convert_unit(data, from, to)
% PSPM_CONVERT_UNIT is a function to convert between different units
% currently only length units are possible.
%
% FORMAT:
%   [sts, converted] = pspm_convert_unit(data, from, to)
%
% ARGUMENTS:
%   data:               The data which should be converted. Must be a numeric 
%                       n x 1 vector.
%   from:               Unit of the input vector.
%   to:                 Unit of the output vector.
% 
% Valid units are currently mm, cm, dm, m, km, in, inches
%______________________________________________________________________________
% PsPM 4.0
% (C) 2018 Tobias Moser (University of Zurich)

% $Id: pspm_convert_au2mm.m 501 2017-11-24 08:36:53Z tmoser $
% $Rev: 501 $

% initialise
% -----------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end
sts = -1;
converted = [];

% define conversion settings
converter = struct('length', ...
    struct(...
        'value', {'mm', 'cm', 'dm', 'm', 'km', 'in', 'inches'}, ...
        'factor', {10^-3, 10^-2, 10^-1, 1, 10^3, 10^-2/2.54, 10^-2/2.54}...
));

% input checks
% -----------------------------------------------------------------------------
if ~isnumeric(data)
    warning('ID:invalid_input', 'Data is not numeric.'); 
    return;
elseif ~any(ismember(from, {converter.length.value})) ...
        || ~any(ismember(to, {converter.length.value}))
    warning('ID:invalid_input', 'Invalid untis specified in from or to.')
    return;
end

[~, from_idx] = ismember(from, {converter.length.value});
[~, to_idx] = ismember(to, {converter.length.value});

from_fact = converter.length(from_idx).factor;
to_fact = converter.length(to_idx).factor;

converted = data*from_fact/to_fact;

end
