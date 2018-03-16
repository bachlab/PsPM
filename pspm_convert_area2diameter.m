function [varargout] = pspm_convert_area2diameter(varargin)
% SCR_CONVERT_AREA2DIAMETER converts area values into diameter values
%
% It can work on PsPM files or on numeric vectors.
%
% FORMAT: 
%   [sts, d] = pspm_convert_area2diameter(area)
%   [sts, chan] = pspm_convert_area2diameter(fn, chan, options)
%
% ARGUMENTS: 
%           fn:                 a numeric vector of milimeter values
%           chan:               Channels which should be converted from
%                               area to diameter. Should be either a string
%                               representing the channels chantype or a
%                               numeric value representing the channels id.
%                               Multiple channels are allowed and should be
%                               provided as cell.
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
if isempty(settings), pspm_init; end
sts = -1;

narginchk(1, 3);

if numel(varargin) == 1
    area = varargin{1};
    
    if ~isnumeric(area)
        warning('ID:invalid_input', 'area is not numeric'); return;
    end
    mode = 'vector';
else
    fn = varargin{1};
    chan = varargin{2};
    
    if ~iscell(chan)
        chan = num2cell(chan);
    end
    
    if numel(varargin) == 3
        options = varargin{3};
    else
        options = struct();
    end
    
    if ~isfield(options, 'channel_action')
        options.channel_action = 'replace';
    end
    
    if ~any(strcmpi(options.channel_action, {'replace', 'add'}))
        warning('ID:invalid_input', ['options.channel_action should ', ...
            'be either ''add'' or ''replace''.']); return;
    end
    
    mode = 'file';
    
end

if strcmpi(mode, 'vector')
    varargout{2} = 2.*sqrt(area.*pi);
    sts = 1;
elseif strcmpi(mode, 'file')
    diam = cell(numel(chan), 1);
    for i = 1:numel(chan)
        [~, ~, data] = pspm_load_data(fn, chan{i});   
        diam{i} = data{1};
        diam{i}.data = 2.*sqrt(diam{i}.data./pi);
        
        % replace metric values
        diam{i}.header.units = ...
            regexprep(data{1}.header.units, ...
            '(square)?(centi|milli|deci|c|m|d)?(m(et(er|re))?)(s?\^?2?)', ...
                '$2$3');
        % if not metric, replace area with diameter
        if strcmpi(diam{1}.header.units, 'area units')
            diam{1}.header.units = 'diameter units';
        end
    end
    [~, infos] = pspm_write_channel(fn, diam, options.channel_action);
    varargout{2} = infos.channel;
    sts = 1;
end
varargout{1} = sts;
