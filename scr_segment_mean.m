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
%       plot:           Display plot of the mean of each condition over 
%                       multiple subjects
%       adjust_method:  How to deal with different sampling rates. Options
%                       are 'none' (Default; will fail if sampling rates
%                       are different), 'downsample' (will sample down to
%                       minimum sample rate), 'interpolate' (will 
%                       interpolate to maximum sample rate)
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

if ~isfield(options, 'adjust_method')
    options.adjust_method = 'none';
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
    warning('ID:invalid_input', 'All elements of segments must have the same length.'); return;
elseif ~any(ismember(options.adjust_method, {'none', 'downsample', 'interpolate'}))
    warning('ID:invalid_input', 'options.adjust_method must be ''none'', ''downsample'' or ''interpolate'''); return;
end;

% if files specified load them
if ischar(segments) || (iscell(segments) && all(cellfun(@ischar, segments)))
    subj_seg = cell(max(size(segments)),1);
    for i = 1:max(size(segments))
        if exist(segments{i}, 'file')
            s = load(segments{i});
            subj_seg{i} = s.segments;
        else
            warning('ID:invalid_input', 'Cannot load segment file %s.', segments{i}); return;
        end;
    end;
else
    subj_seg = segments;
end;

n_subjects = size(subj_seg,1);

if n_subjects == 1
    warning('ID:invalid_input', 'Cannot create a mean over 1 subject.'); return;
end;

n_cond = size(subj_seg{1},1);
conditions = cell(n_cond,1);

if options.plot
    fh = figure('Name', 'Condition grand mean (multiple subjects)');
    ax = axes(fh, 'NextPlot', 'add');
end;

for c = 1:n_cond
    sr = cellfun(@(x) size(x{c}.mean,1)/max(x{c}.t), subj_seg);
    if sum(diff(sr)) ~= 0
        switch options.adjust_method
            case 'none'
                warning('ID:invalid_input', ['Adjust method is ''none'' ', ...
                    'but files have different sampling rates.']); return;
            case 'downsample'
                min_sr = min(sr);
                factors = sr./min_sr;
                subj = find(sr == min_sr);
                subj_t = subj_seg{subj(1)}{c}.t;
                
                for i= 1:size(subj_seg, 1)
                    f = factors(i);
                    if f > 1
                        subj_seg{i}{c}.mean = subj_seg{i}{c}.mean(1:f:end);
                        subj_seg{i}{c}.t = subj_t;
                    end;
                end;
            case 'interpolate'
                max_sr = max(sr);
                subj = find(sr == max_sr);
                subj_t = subj_seg{subj(1)}{c}.t;
                
                for i = 1:size(subj_seg, 1)
                    if sr(i) < max_sr()
                        subj_seg{i}{c}.mean = interp1(subj_seg{i}{c}.t, subj_seg{i}{c}.mean, subj_t);
                        subj_seg{i}{c}.t = subj_t;
                    end;
                end;
        end;
    end;
    
    conditions{c}.data = NaN(size(subj_seg{1}{c}.mean,1), n_subjects);
    for s = 1:n_subjects
        conditions{c}.data(:,s) = subj_seg{s}{c}.mean;
    end;
    m = conditions{c}.data;
    conditions{c}.mean = mean(m,2);
    conditions{c}.std = std(m,0,2);
    conditions{c}.sem = conditions{c}.std/sqrt(n_subjects);
    conditions{c}.t = subj_seg{1}{c}.t;
    
    if options.plot
        p = plot(ax, conditions{c}.t, conditions{c}.mean, '-', ...
            conditions{c}.t, conditions{c}.mean + conditions{c}.sem, '-', ...
            conditions{c}.t, conditions{c}.mean - conditions{c}.sem, '-');
        % correct colors
        set(p(1), 'LineWidth', 2);
        set(p(2), 'Color', get(p(1), 'Color'));
        set(p(3), 'Color', get(p(1), 'Color'));
    end;
end;

sts = 1;

