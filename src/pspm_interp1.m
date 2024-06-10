function Y = pspm_interp1(varargin)
% ● Description
%   pspm_interp1 is a shared PsPM function for interpolating data with NaNs
%   based on the reference of missing epochs and first order interpolation.
% ● Format
%   Y = pspm_interp1(varargin)
% ● Arguments
%   X:              data that contains NaNs to be interpolated
%   index_missing:  index of missing epochs with the same size of X in binary
%                   values. 1 if NaNs, 0 if non-NaNs.
%   Y:              processed data
% ● History
%   Introduced in PsPM 6.1
%   Written in 2023 by Teddy

%% 1 Load inputs
switch nargin
  case 1
    X = varargin{1};
    index_missing = zeros(size(X));
  case 2
    X = varargin{1};
    index_missing = varargin{2};
  otherwise
    warning('ID:invalid_input','pspm_interp1 accepts up to two arguments');
end
%% 2 Check inputs
switch sum(~isnan(X))
  case 0
    % if there are no non-nans, do not process any interpolation, give a
    % warning and return
    warning('ID:invalid_input',...
      'Input data contains only NaNs thus cannot be interpolated.')
    Y = X;
    return
  case 1
    % if there are only 1 non-nan, do not process any interpolation,
    % give a warning and explain the reason
    warning('ID:invalid_input',...
      'Input data contains only 1 non-NaN thus cannot be interpolated.')
    Y = X;
    return
  otherwise
    % if there are less than 10^ non-nan, still perform interpolation,
    % however give a warning and explain the reason
    non_nan_percentage = sum(~isnan(X))/length(X);
    if non_nan_percentage<0.1
      warning('ID:invalid_input',...
      'Input data contains less than 10% non-NaN. Interpolation can ',... 
      'still be performed but results could be inaccurate.')
    end
end
%% 3 find nan head and tail
X_nan_head = 0;
X_nan_tail = 0;
X_nan_head_range = [];
X_nan_tail_range = [];
X_nan_head_interp = [];
X_nan_tail_interp = [];
index_non_nan_full = 1:length(X);
index_non_nan_full = index_non_nan_full(~isnan(X));
if index_non_nan_full(1) > 1
  X_nan_head = 1;
  X_nan_head_range = 1:(index_non_nan_full(1)-1);
end
if index_non_nan_full(end) < length(X)
  X_nan_tail = 1;
  X_nan_tail_range = (index_non_nan_full(end)+1):length(X);
end
X_body = X(index_non_nan_full(1):index_non_nan_full(end));
% processing body
index_nan = zeros(size(X_body));
index_nan(isnan(X_body) | index_missing(index_non_nan_full(1):index_non_nan_full(end))) = 1;
if any(index_nan)
  X_body_interp = interp1(find(~index_nan),X_body(~index_nan), (1:numel(X_body))');
else
  X_body_interp = X_body;
end
% interpolate head
if X_nan_head
  X_nan_head_interp = interp1(...
    (1:length(X_body_interp))+length(X_nan_head_range),...
    X_body_interp,...
    X_nan_head_range,'linear','extrap');
end
% interpolate tail
if X_nan_tail
  X_nan_tail_interp = interp1(...
    (1:length(X_body_interp))+length(X_nan_head_range),...
    X_body_interp,...
    X_nan_tail_range,'linear','extrap');
end
if iscolumn(X_body_interp)
  if ~iscolumn(X_nan_head_interp)
    X_nan_head_interp = transpose(X_nan_head_interp);
  end
  if ~iscolumn(X_nan_tail_interp)
    X_nan_tail_interp = transpose(X_nan_tail_interp);
  end
  Y = [X_nan_head_interp; X_body_interp; X_nan_tail_interp];
else
  if iscolumn(X_nan_head_interp)
    X_nan_head_interp = transpose(X_nan_head_interp);
  end
  if iscolumn(X_nan_tail_interp)
    X_nan_tail_interp = transpose(X_nan_tail_interp);
  end
  Y = [X_nan_head_interp, X_body_interp, X_nan_tail_interp];
end
return
