function [varargout] = scr_convert_area2diameter(varargin)
% SCR_CONVERT_AREA2DIAMETER converts area values into diameter
%
% It can work on PsPM files or on numeric vectors.
%
% FORMAT: 
%   [sts, d] = scr_convert_area2diameter(area)
%   [sts, chan] = scr_convert_area2diameter(fn, chan, options)
%
% ARGUMENTS: 
%           fn:                 a numeric vector of milimeter values
%           chan:               distance between screen and eyes in meter
%           area:               a numeric vector of area values (the unit
%                               is not important)
%           options:
%               channel_action: 'replace' or 'add' processed data
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
d = [];

narginchk(1, 3);

if numel(varargin) == 1
    area = varargin{1};
    
    if ~isnumeric(area)
        warning('ID:invalid_input', 'area is not numeric'); return;
    end;
    mode = 'vector';
else
    fn = varargin{1};
    chan = varargin{2};
    
    if numel(varargin) == 3
        options = varargin{3};
    else
        options = struct();
    end;
    
    if ~isfield(options, 'channel_action')
        options.channel_action = 'replace';
    end;
    
    if ~any(strcmpi(options.channel_action, {'replace', 'add'}))
        warning('ID:invalid_input', 'options.channel_action should be either ''add'' or ''replace''.'); return;
    end;
    
    mode = 'file';
    
    [~, ~, data] = scr_load_data(fn, chan);
    area = data{1}.data;
end;

d = 2.*sqrt(area.*pi);
sts = 1;
if strcmpi(mode, 'file')
    data{1}.data = d;
    % replace metric values
    data{1}.header.units = ...
        regexprep(data{1}.header.units, ...
            '(square)?(centi|milli|deci|c|m|d)?(m(et(er|re))?)(s?\^?2?)', '$2$3');
    % if not metric, replace area with diameter
    if strcmpi(data{1}.header.units, 'area')
        data{1}.header.units = 'diameter';
    end;
    [~, infos] = scr_write_channel(fn, data{1}, options.channel_action);
    varargout{2} = infos.channel;
else
    varargout{2} = d;
end;
varargout{1} = sts;