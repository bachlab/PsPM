function [sts, cd] = pspm_convert_lux2cdm2(lux, screen)
% SCR_CONVERT_LUX2CDM2 converts lux values to cd/m^2 values. In other words
% a conversion from illuminance (what we measure with the light meter) to
% luminance
%
% It can work on PsPM files (not jet) or on numeric vectors.
% 
%
% FORMAT: 
%   [sts, cd] = pspm_convert_lux2cdm2(lux, screen)
%
% ARGUMENTS: 
%           lux:                a numeric vector of lux values
%           screen:             a struct with the following fields
%               diameter:       screen diameter in inches
%               distance:       distance between screen and eyes in meter
%               aspect_actual:  actual aspect ratio of the screen (property
%                               of the hardware). a 1x2 vector is espected 
%                               e.g. [16 9]
%               aspect_used:    used aspect ratio of the screen (set in the
%                               software) (optional). a 1x2 vector is 
%                               expected e.g. [5 4]
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)
%
% $Id$
% $Rev$
%
% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end
sts = -1;
cd = [];

isposscalar = @(x) isnumeric(x) && isscalar(x) && isfinite(x) && x > 0;
ispos2vec   = @(x) isnumeric(x) && numel(x) == 2 && all(isfinite(x)) && all(x > 0);

if ~isnumeric(lux)
    warning('ID:invalid_input', 'Lux is not numeric.'); return;
elseif ~isstruct(screen)
    warning('ID:invalid_input', 'Screen is not a struct.'); return;
elseif ~isfield(screen, 'diameter') || ~isposscalar(screen.diameter)
    warning('ID:invalid_input', 'screen.diameter must be a positive finite scalar.'); return;
elseif ~isfield(screen, 'distance') || ~isposscalar(screen.distance)
    warning('ID:invalid_input', 'screen.distance must be a positive finite scalar.'); return;
elseif ~isfield(screen, 'aspect_actual') || ~ispos2vec(screen.aspect_actual)
    warning('ID:invalid_input', 'screen.aspect_actual must be a vector of two positive numbers.'); return;
elseif isfield(screen, 'aspect_used') && ~ispos2vec(screen.aspect_used)
    warning('ID:invalid_input', 'screen.aspect_used must be a vector of two positive numbers.'); return;
end

% default value from aspect_actual
if ~isfield(screen, 'aspect_used')
    screen.aspect_used = screen.aspect_actual;
end

% do conversion
dia_cm = screen.diameter*2.54;
h = sqrt((screen.aspect_actual(2)*dia_cm)^2 / (sum(screen.aspect_actual.^2)))/100; % [h] = m
w = h*screen.aspect_used(1)/screen.aspect_used(2); % h*a/b = w ; h is already in m!

cd = (lux.*screen.distance^2)/(h*w);
sts = 1;





