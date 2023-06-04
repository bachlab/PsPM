function [sts, out] = pspm_segment_mean(segments, options)
% ● Description
%   pspm_segment_mean is a function which takes segments created by
%   pspm_extract_segments and creates means among sessions.
% ● Format
%   [sts, out] = pspm_segment_mean(segments, options)
% ● Arguments
%         segments: Cell of multiple segments, each obtained with
%                   pspm_extract_segments()
%   ┌──────options:
%   ├─────────plot: Display plot of the mean of each condition over multiple
%   │               subjects
%   ├adjust_method: How to deal with different sampling rates. Accepted values
%   │               are 'none' (Default; will fail if sampling rates are
%   │               different), 'downsample' (will sample down to minimum
%   │               sample rate), 'interpolate' (will interpolate to maximum
%   │               sample rate).
%   ├──────newfile: If specified, the segment data will be written into file
%   │               specified. If is equal to '' (empty) then data will not be
%   │               returned. If written to file. The file is also speciefied
%   │               in the out struct. Default is ''.
%   └────overwrite: [logical] (0 or 1)
%                   Define whether to overwrite existing output files or not.
%                   Default value: determined by pspm_overwrite.
% ● History
%   Introduced in PsPM 3.1
%   Written in 2008-2016 by Tobias Moser (University of Zurich)
%   Maintained in 2022 by Teddy Chao (UCL)

%% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
out = struct();

if nargin < 2
  options = struct();
end
options = pspm_options(options, 'segment_mean');
if options.invalid
  return
end
if nargin > 1 && ~isstruct(options)
  warning('ID:invalid_input', 'Options must be a struct.'); return;
elseif ~(iscell(segments) || ischar(segments)) || ...
    (iscell(segments) && any(~cellfun(@(x) iscell(x) || ischar(x), segments)))
  warning('ID:invalid_input', ['The function expects segments to be a ', ...
    'cell of cells or a cell of strings.']); return;
end

% if files specified load them
if ischar(segments) || (iscell(segments) && all(cellfun(@ischar, segments)))
  subj_seg = cell(max(size(segments)),1);
  for i = 1:max(size(segments))
    if exist(segments{i}, 'file')
      s = load(segments{i});
      subj_seg{i} = s.segments;
    else
      warning('ID:invalid_input', 'Cannot load segment file %s.', segments{i}); return;
    end
  end
else
  subj_seg = segments;
end

if any(diff(cellfun(@numel, subj_seg)))
  warning('ID:invalid_input', 'All elements of segments must have the same length.'); return;
end

n_subjects = size(subj_seg,1);

if n_subjects == 1
  warning('ID:invalid_input', 'Cannot create a mean over 1 subject.'); return;
end

n_cond = size(subj_seg{1},1);
conditions = cell(n_cond,1);

if options.plot
  fh = figure('Name', 'Condition grand mean (multiple subjects)');
  ax = axes('NextPlot', 'add');
  set(fh, 'CurrentAxes', ax);
end

legend_lb = cell(1,n_cond*3);
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
          end
        end
      case 'interpolate'
        max_sr = max(sr);
        subj = find(sr == max_sr);
        subj_t = subj_seg{subj(1)}{c}.t;

        for i = 1:size(subj_seg, 1)
          if sr(i) < max_sr
            subj_seg{i}{c}.mean = interp1(subj_seg{i}{c}.t, subj_seg{i}{c}.mean, subj_t);
            subj_seg{i}{c}.t = subj_t;
          end
        end
    end
  end
  seg_size = cellfun(@(x) size(x{c}.mean, 1), subj_seg);
  min_size = min(seg_size);
  min_el = find(seg_size == min_size,1);
  conditions{c}.data = NaN(min_size, n_subjects);
  for s = 1:n_subjects
    conditions{c}.data(:,s) = subj_seg{s}{c}.mean(1:min_size);
  end
  m = conditions{c}.data;
  conditions{c}.mean = nanmean(m,2);
  conditions{c}.std = nanstd(m,0,2);
  conditions{c}.sem = conditions{c}.std/sqrt(n_subjects);
  conditions{c}.name = subj_seg{s}{c}.name;
  conditions{c}.t = subj_seg{min_el}{c}.t;

  if options.plot
    p = plot(ax, conditions{c}.t, conditions{c}.mean, '-', ...
      conditions{c}.t, conditions{c}.mean + conditions{c}.sem, '-', ...
      conditions{c}.t, conditions{c}.mean - conditions{c}.sem, '-');
    % correct colors
    set(p(1), 'LineWidth', 2);
    set(p(2), 'Color', get(p(1), 'Color'));
    set(p(3), 'Color', get(p(1), 'Color'));

    nm = conditions{c}.name;
    legend_lb{(c-1)*3 + 1} = [nm ' AVG'];
    legend_lb{(c-1)*3 + 2} = [nm ' SEM+'];
    legend_lb{(c-1)*3 + 3} = [nm ' SEM-'];
  end
end
if options.plot
  legend(legend_lb);
end
out.conditions = conditions;
if ~isempty(options.newfile)
  [pathstr, ~, ~] = fileparts(options.newfile);
  if exist(pathstr, 'dir')
    if pspm_overwrite(options.newfile, options)
      segment_mean = conditions;
      save(options.newfile, 'segment_mean');
    end
  else
    warning('ID:invalid_input', 'Path specified in options.newfile does not seem to exist.');
  end
  out.file = options.newfile;
end
sts = 1;
return
