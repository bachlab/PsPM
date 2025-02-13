function [bs, x] = pspm_bf_lcrf_gm(varargin)
% ● Description
%   pspm_bf_lcrf_gm is the gamma response function for pupil constriction.
%   Pupil size models were developed with pupil size data recorded in
%   diameter values. Therefore pupil size data analyzed using these models
%   should also be in diameter.
% ● Format
%   [bs, x] = pspm_bf_lcrf_gm(td, n, offset, a, b, A)
%   [bs, x] = pspm_bf_lcrf_gm([td, n, offset, a, b, A])
% ● Arguments
%   *    td : time resolution in second.
%   *     n : duration of the function in s. Default as 20 s.
%   * offset: offset of the response function (in s).
%   *     a : shape of the function.
%   *     b : scale of the function.
%   *     A : quantifier or amplitude of the function
% ● References
%   Korn CW, Bach DR.
%   A solid frame for the window on cognition: Modeling event-related pupil responses.
%   J Vis. 2016;16(3):28. doi: 10.1167/16.3.28.
% ● History
%   Introduced in PsPM 3.1
%   Written in 2015 by Tobias Moser (University of Zurich)
%   Maintained in 2022 by Teddy

%% initialise
global settings
if isempty(settings), pspm_init; end
%% set defaults
a = 3.24;
b = 0.18;
A = 0.43;
offset = 0.2;
n = 20;
%% check input arguments
if nargin==0
  errmsg='No sampling interval stated'; warning('ID:invalid_input',errmsg); return;
elseif nargin == 1
  n_el = numel(varargin{1});
  td = varargin{1}(1);
  if n_el > 1, n = varargin{1}(2); end
  if n_el > 2, offset = varargin{1}(3); end
  if n_el > 3, a = varargin{1}(4); end
  if n_el > 4, b = varargin{1}(5); end
  if n_el > 5, A = varargin{1}(6); end
elseif nargin > 1
  td = varargin{1};
  n = varargin{2};
  if nargin > 2, offset = varargin{3}; end
  if nargin > 3, a = varargin{4}; end
  if nargin > 4, b = varargin{5}; end
  if nargin > 5, A = varargin{6}; end
end
if td > n
  warning('ID:invalid_input', 'Time resolution is larger than the duration of the function.'); return;
elseif td == 0
  warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
elseif offset <= 0
  warning('ID:invalid_input', 'Offset has to be a positive.'); return;
elseif n <= 0
  warning('ID:invalid_input', 'Duration has to be a number larger then 0.'); return;
end
%% check if offset is in a valid range or correct it if it is to small
if offset ~= 0
  r = td/offset;
  if r > 1
    % td is bigger than offset -> offset is too small
    if r > 2
      offset = 0;
    elseif r <= 2
      offset = td;
    end
  end
end
%% create x axis
bf_dur = n;
n_bf = round((bf_dur)/td);
bs = zeros(1, n_bf);
x2 = linspace(offset+td,bf_dur,round((bf_dur-offset)/td));
x1 = linspace(0,offset,offset/td);
x = [x1, x2];
%% apply gamma function
gl = gammaln(a);
bs(round(offset/td + 1):end) = A * exp(log(x2-offset).*(a-1) - gl - (x2-offset)./b - log(b)*a);
return
