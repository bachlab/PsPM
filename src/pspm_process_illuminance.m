function [sts, out] = pspm_process_illuminance(ldata, sr, options)
% ● Description
%   pspm_process_illuminance is used to process raw lux data and transfer
%   it into two nuisance regressors (dilation and constriction) for glm
% ● Developer's Notes
%   Pupil size models were developed with pupil size data recorded in
%   diameter values. Therefore pupil size data analyzed using these models
%   should also be in diameter.
% ● Format
%   [sts, out] = pspm_process_illuminance(ldata, sr, options)
% ● Arguments
%           ldata:  illuminance data as (cell of) 1x1 double or filename
%              sr:  sample rate in Hz of the input data
%   ┌─────options:  struct with optional settings
%   ├───.transfer:  params for the transfer function
%   ├─────────.bf:  settings for the basis functions
%   ├───.duration:  duration of the basis functions in s
%   ├─────.offset:  offset in s
%   ├───.dilation:  options for the dilation basis function
%   ├────.fhandle:  function handle to the dilation response function.
%   ├.constriction:
%   ├────.fhandle:  function handle to the constriction response function.
%   ├─────────.fn:  [filename] if specified ldata{i,j} will be saved to a file
%   │               with filename options.fn{i,j} into the variable 'R'.
%   └──.overwrite:  [logical] (0 or 1)
%                   Define whether to overwrite existing output files or not.
%                   Default value: determined by pspm_overwrite.
% ● Outputs
%             sts:  status
%             out:  has same size as ldata and contains either the
%                   processed data or contains the path to the .mat file
%                   where the data has been stored to
% ● History
%   Introduced In PsPM 3.1
%   Written in 2015 by Tobias Moser, Christoph Korn (University of Zurich)
%   Maintained in 2022 by Teddy Chao (UCL)

% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
out = {};

% check options
if nargin < 3
  options = struct();
elseif ~isstruct(options)
  warning('ID:invalid_input', 'Options must be a structure.'); return;
end

% setup default values
options = pspm_options(options, 'process_illuminance');
if options.invalid
  return
end

% ensure parameters are correct
% -------------------------------------------------------------------------
if nargin < 1
  warning('ID:invalid_input', 'Missing input data.'); return;
elseif isempty(ldata)
  warning('ID:missing_data', 'Empty illuminance data.'); return;
elseif ~isnumeric(ldata) && ~ischar(ldata) && ~iscell(ldata)
  warning('ID:invalid_input', 'Illuminance data has to be numeric, a string or a cell.'); return;
elseif nargin < 2
  warning('ID:invalid_input', 'Missing sample rate.'); return;
elseif ~isnumeric(sr) && ~iscell(sr)
  warning('ID:invalid_input', 'Sample rate must be numeric.'); return;
elseif ~isempty(options.fn) && (iscell(ldata) && ~iscell(options.fn)) || ...
    (~iscell(ldata) && iscell(options.fn))
  warning('ID:invalid_input', 'ldata and options.fn have not the same dimension.');
  return;
elseif ~isnumeric(options.bf.duration)
  warning('ID:invalid_input', 'options.bf.duration must be numeric.');
  return;
elseif ~isnumeric(options.bf.offset)
  warning('ID:invalid_input', 'options.bf.offset must be numeric.');
  return;
elseif ~isa(options.bf.constriction.fhandle, 'function_handle')
  warning('ID:invalid_input', ['options.bf.constriction.fhandle has', ...
    ' to be a valid function handle.']); return;
elseif ~isa(options.bf.dilation.fhandle, 'function_handle')
  warning('ID:invalid_input', ['options.bf.dilation.fhandle has', ...
    ' to be a valid function handle.']); return;
elseif ~isnumeric(options.transfer) || ~isequal(size(options.transfer), [1 3])
  warning('ID:invalid_input','options.transfer must be a 1x3 numeric.');
  return;
end

% if one is not a cell
if ~(iscell(ldata) && iscell(sr))
  % if both are not cells
  if ~iscell(ldata) && ~iscell(sr)
    ldata = {ldata};
    sr = {sr};
    if ~isempty(options.fn)
      options.fn = {options.fn};
    end
  else
    warning('ID:invalid_input', 'If either ldata or sr is a cell the other has to be a cell too.'); return;
  end
else
  % both are cells check if content has correct format
  if any(cellfun(@(x) ~ischar(x) && ~isnumeric(x), ldata))
    warning('ID:invalid_input', 'Contents of ldata have to be either numeric or char.');
    return;
  elseif any(~cellfun(@(x) isnumeric(x), sr))
    warning('ID:invalid_input', 'Contents of sample rate have to be numeric.');
    return;
  end
end

if ~isequal(size(ldata), size(sr))
  warning('ID:invalid_input', 'Dimension of ldata and sr is not the same.');
  return;
elseif ~isempty(options.fn) && ~isequal(size(ldata), size(options.fn))
  warning('ID:invalid_input', 'Dimension of ldata and options.fn is not the same.');
  return;
end

% cycle through data
[w, h] = size(ldata);
for i = 1:w
  for j = 1:h
    % initialise data variables
    % -----------------------------------------------------------------
    if ischar(ldata{i,j})
      lum_file = ldata{i,j};
      if exist(lum_file, 'file')
        % load file test for Lx
        lf_vars = load(lum_file);
        if isfield(lf_vars, 'Lx')
          if iscell(lf_vars.Lx)
            % just take the first
            lumd = lf_vars.Lx{1,1};
          else
            lumd = lf_vars.Lx;
          end

        else
          warning('ID:invalid_data_structure', 'File ''%s'' contains no variable called ''Lx''', lum_file);
          return;
        end
      else
        warning('ID:non_existent_file', 'File ''%s'' does not exist.', ldata{i,j});
        return;
      end
    else
      lumd = ldata{i,j};
    end

    s = size(lumd);
    if (s(1) ~= 1 && s(2) ~= 1) || ~isnumeric(lumd) || isempty(lumd)
      warning('ID:invalid_input', ['Illuminance data is empty, not numeric ', ...
        'or not 1xn ldata{%i,%i}'], i,j);
      return;
    elseif s(1) < s(2)
      % transpose data
      lumd = transpose(lumd);
    end

    lsr = sr{i,j};
    n_bf = options.bf.duration*lsr;

    if n_bf < 1
      warning('ID:invalid_input', 'Unrealistic combination of bf duration and sample rate.'); return;
    end

    lumd = [repmat(lumd(1),n_bf,1);lumd];

    % transfer data
    transd = zeros(numel(lumd), 1);
    % event data
    eventd = zeros(numel(lumd), 1);
    % regressor data
    regd = zeros(numel(lumd)-n_bf, 2);

    % calculate duration in s
    dur = (numel(lumd)-n_bf)/lsr;

    % transfer illuminance data into steady state data
    % -----------------------------------------------------------------

    p = options.transfer;
    a = p(1);
    b = p(2);
    c = p(3);
    transd = -(a * exp(lumd * c) + b);

    % find changes
    % -----------------------------------------------------------------

    % find events of increasing illuminance
    ev = diff(lumd) > 0;
    ev(end+1) = 0;

    eventd = +ev;

    % create regressor 1 (bf1)
    % -----------------------------------------------------------------
    % collect parameters
    p_offset = options.bf.offset;
    p_dur = options.bf.duration;

    bf1d = zeros(n_bf, 1);
    bf1d(:) = feval(options.bf.dilation.fhandle, lsr^-1, p_dur, p_offset);

    % create regressor 2 (bf2)
    % -----------------------------------------------------------------
    % bf2: constriction
    bf2d = zeros(n_bf, 1);
    bf2d(:) = feval(options.bf.constriction.fhandle, lsr^-1, p_dur, p_offset);

    % scale data max(abs(.)) should be 1 and min(.) should be 0
    % -----------------------------------------------------------------
    bf1d = bf1d - min(bf1d);
    bf2d = bf2d - min(bf2d);

    bf1d = bf1d/max(abs(bf1d));
    bf2d = bf2d/max(abs(bf2d));

    % convolve ready state with bf's
    % -----------------------------------------------------------------
    tmp_reg1 = conv(transd, bf1d);
    tmp_reg2 = conv(eventd, bf2d);
    regd(:, 1) = tmp_reg1((n_bf+1):(dur*lsr+n_bf))*(-1);
    regd(:, 2) = tmp_reg2((n_bf+1):(dur*lsr+n_bf))*(-1);
    % care about correct output
    if ~isempty(options.fn) && ischar(options.fn{i,j})
      fn = options.fn{i,j};
      save_file = pspm_overwrite(fn, options);
      if save_file
        R = regd;
        save(fn, 'R');
        reg{i,j} = fn;
      else
        reg{i,j} = regd;
      end
    else
      reg{i,j} = regd;
    end
  end

end

if isequal(size(reg),[1 1])
  reg = reg{1};
end

out = reg;
sts = 1;
return
