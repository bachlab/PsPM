function [varargout] = scr_convert_mm2visdeg(varargin)
% SCR_CONVERT_MM2VISDEG converts milimeter values to visual degree values.
%
% It can work on PsPM files or on numeric vectors.
%
% FORMAT: 
%   [sts, vd] = scr_convert_mm2visdeg(mm, distance)
%   [sts, chan] = scr_convert_mm2visdeg(fn, chan, distance, options)
%
% ARGUMENTS: 
%           fn:                 a char which points to a PsPM file
%           chan:               a numeric value which corresponds to the
%                               channel id of the channel which should 
%                               be processed
%           mm:                 a numeric vector of milimeter values
%           distance:           distance between screen and eyes in meter
%           options:
%               channel_action: 'replace' or 'add' processed data
%               
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sts = -1;

narginchk(2,4);
if numel(varargin) == 2
    mm = varargin{1};
    distance = varargin{2};
    
    if ~isnumeric(mm)
        warning('ID:invalid_input', 'mm is not numeric');
    end;
    mode = 'vector';
else
    fn = varargin{1};
    chan = varargin{2};
    distance = varargin{3};
    if numel(varargin) == 4
        options = varargin{4};
    else
        options = struct();
    end;
    
    if ~isfield(options, 'channel_action')
        options.channel_action = 'replace';
    end;
    
    if ~any(strcmpi(options.channel_action, {'replace', 'add'}))
        warning('ID:invalid_input', 'options.channel_action should be either ''add'' or ''replace''.'); return;
    end;
    
    [~, ~, data] = scr_load_data(fn, chan);
    mm = data{1}.data;
    
    mode = 'file';
end;

if ~isnumeric(distance)
    warning('ID:invalid_input', 'distance is not numeric'); return;
end;

d_mm = distance*1000;
vd = 2.*atan(mm ./ (2*d_mm)).*180./pi;
sts = 1;

if strcmpi(mode, 'file')
    data{1}.data = vd;
    [~, info] = scr_write_channel(fn, data{1}, options.channel_action);
    varargout{2} = info.channel;
else
    varargout{2} = vd;
end;

varargout{1} = sts;