function [sts, conditions] = scr_segment_mean(segments, options)
% SCR_SEGMENT_MEAN is a function which takes segments created by 
% scr_extract_segments and creates means among sessions.
%
% FORMAT: 
%   [sts, segment_mean] = scr_segment_mean(segments, options)
%
% INPUT:
%   segments:           Cell of multiple segments, each obtained with
%                       scr_extract_segments()
%   options:
%       plot:                   
%__________________________________________________________________________
% PsPM 3.1
% (C) 2008-2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sts = -1;
conditions = {};

if nargin < 2
    options = struct();
end;

if ~isfield(options, 'plot')
    options.plot = 0;
end;

if nargin > 1 && ~isstruct(options)
    warning('ID:invalid_input', 'Options must be a struct.'); return;
elseif ~isnumeric(options.plot)
    warning('ID:invalid_input', 'Options.plot must be numeric.'); return;
elseif ~(iscell(segments) || ischar(segments)) || ...
        (iscell(segments) && any(~cellfun(@(x) iscell(x) || ischar(x), segments)))
    warning('ID:invalid_input', ['The function expects segments to be a ', ...
        'cell of cells or a cell of strings.']); return;
elseif any(diff(cellfun(@numel, segments)))
    warning('ID:invalid_input', 'All elements of segments must have the same length.');
end;

n_subjects = size(segments,1);

if n_subjects == 1
    warning('ID:invalid_input', 'Can not create a mean over 1 subject.'); return;
end;

n_cond = size(segments{1},1);
conditions = cell(n_cond,1);

if options.plot
    fh = figure('Name', 'Condition grand mean (multiple subjects)');
    ax = axes(fh, 'NextPlot', 'add');
end;

for c = 1:n_cond
    conditions{c}.data = NaN(size(segments{1}{c}.mean,1), n_subjects);
    for s = 1:n_subjects
        conditions{c}.data(:,s) = segments{s}{c}.mean;
    end;
    m = conditions{c}.data;
    conditions{c}.mean = mean(m,2);
    conditions{c}.std = std(m,0,2);
    conditions{c}.sem = conditions{c}.std/sqrt(n_subjects);
    conditions{c}.t = segments{1}{c}.t;
    
    if options.plot
        p = plot(ax, conditions{c}.t, conditions{c}.mean, '-', ...
            conditions{c}.t, conditions{c}.mean + conditions{c}.sem, '--', ...
            conditions{c}.t, conditions{c}.mean - conditions{c}.sem, '--');
        % correct colors
        set(p(2), 'Color', get(p(1), 'Color'));
        set(p(3), 'Color', get(p(1), 'Color'));
    end;
end;

sts = 1;

