function [varargout] = scr_convert_lux2cdm2(varargin)
% SCR_CONVERT_LUX2CDM2 converts lux values to cd/m^2 values. In other words
% a conversion from illuminance (what we measure with the light meter) to
% luminance
%
% It can work on PsPM files or on numeric vectors.
% 
%
% FORMAT: 
%   [sts, cd] = scr_convert_lux2cdm2(lux, screen)
%   [sts, chan] = scr_convert_lux2cdm2(fn, chan, screen, options)
%
% ARGUMENTS: 
%           fn:                 a numeric vector of milimeter values
%           chan:               distance between screen and eyes in meter
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
%           options:
%               channel_action: 'replace' or 'add' processed data.
%               
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
if isempty(settings), scr_init; end;
sts = -1;


narginchk(2,4);

if numel(varargin) == 2
    lux = varargin{1};
    screen = varargin{2};
    
    mode = 'vector';
    
    if ~isnumeric(lux)
        warning('ID:invalid_input', 'Lux is not numeric.'); return;
    end;
    
else
    fn = varargin{1};
    chan = varargin{2};
    screen = varargin{3};
    if numel(varargin) == 4
        options = varargin{4};
    else
        options = struct();
    end;
    
    if ~isfield(options, 'channel_action')
        options.channel_action = 'add';
    end;
    
    if ~any(options.channel_action, {'add', 'replace'})
        warning('ID:invalid_input', 'options.channel_action should be either ''add'' or ''replace''.'); return;
    end;
    
    mode = 'file';
    
    [~, ~, data] = scr_load_data(fn, chan);
    lux = data{1}.data;
end;

if ~isstruct(screen)
    warning('ID:invalid_input', 'Screen is not a struct.'); return;
elseif ~isfield(screen, 'diameter') || ~isnumeric(screen.diameter)
    warning('ID:invalid_input', 'screen.diameter does not exist or is not numeric.');
elseif ~isfield(screen, 'distance') || ~isnumeric(screen.distance)
    warning('ID:invalid_input', 'screen.distance does not exist or is not numeric.');
elseif ~isfield(screen, 'aspect_actual') || ~isnumeric(screen.aspect_actual)
    warning('ID:invalid_input', 'screen.aspect_actual does not exist or is not numeric.'); return;
elseif isfield(screen, 'aspect_used') && ~isnumeric(screen.aspect_used)
    warning('ID:invalid_input', 'screen.aspect_used is not numeric.'); return;
end;

% default value from aspect_actual
if ~isfield(screen, 'aspect_used')
    screen.aspect_used = screen.aspect_actual;
end;

% do conversion
dia_cm = screen.diameter*2.54;
h = sqrt((screen.aspect_actual(2)*dia_cm)^2 / (sum(screen.aspect_actual.^2)))/100;
w = h*screen.aspect_used(1)/screen.aspect_used(2)/100;

cd = (lux.*screen.distance^2)/(h*w);

if strcmpi(mode, 'file')
    data{1}.data = cd;
    [~, info] = scr_write_channel(fn, data{1}, options.channel_action);
    sts = 1;
    varargout{2} = info.channel;
else
    sts = 1;
    varargout{2} = cd;
end;

varargout{1} = sts;






