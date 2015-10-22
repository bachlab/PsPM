function [bs, x] = scr_bf_lcrf_gm(varargin)
% SCR_bf_lcrf_gm  
% Description: 
%
% FORMAT: [bs, x] = scr_bf_lcrf_gm(td, n, offset, a, b, A) 
%     OR: [bs, x] = scr_bf_lcrf_gm([td, n, offset, a, b, A])
%
%   Inputs:
%       td:         time resolution in s
%        n:         duration of the function in s [20s]
%   offset:         offset in s. tells the function where to start with 
%                   the response function [0.2s]
%        a:         shape of the function
%        b:         scale of the function
%        A:         quantifier or amplitude of the function
%
% REFERENCE
%
%________________________________________________________________________
% PsPM 3.1
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$   
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings
if isempty(settings), scr_init; end;

% set defaults
% -------------------------------------------------------------------------
a = 2.36014158356245;
b = 0.283916258442016;
A = 0.684370683567310;

offset = 0.2;
n = 20;

% check input arguments
% -------------------------------------------------------------------------
if nargin==0
    errmsg='No sampling interval stated'; warning('ID:invalid_input',errmsg); return;
elseif nargin == 1
    n_el = numel(varargin{1});
    td = varargin{1}(1);
    if n_el > 1, n = varargin{1}(2); end;
    if n_el > 2, offset = varargin{1}(3); end;
    if n_el > 3, a = varargin{1}(4); end;
    if n_el > 4, b = varargin{1}(5); end;
    if n_el > 5, A = varargin{1}(6); end;
elseif nargin > 1
    td = varargin{1};
    n = varargin{2};
    if nargin > 2, offset = varargin{3}; end;
    if nargin > 3, a = varargin{4}; end;
    if nargin > 4, b = varargin{5}; end;
    if nargin > 5, A = varargin{6}; end;
end;

if td > n
    warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
    warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
elseif offset <= 0 
    warning('ID:invalid_input', 'Offset has to be a positive.'); return;
elseif n <= 0 
    warning('ID:invalid_input', 'Duration has to be a number larger then 0.'); return;
end;

% check if offset is in a valid range or correct it if it is to small
if offset ~= 0
    r = td/offset;
    if r > 1
        % td is bigger than offset -> offset is too small
        if r > 2 
            offset = 0;
        elseif r <= 2
            offset = td;
        end;
    end;
end;

% create x axis 
% -------------------------------------------------------------------------
bf_dur = n;

n_bf = bf_dur/td;
bs = zeros(1, n_bf);
x2 = linspace(0,(bf_dur-offset)-td,(bf_dur-offset)/td);
x1 = linspace(0,offset-td,offset/td);
x = [x1, (x2+offset)];

% apply gamma function
% -------------------------------------------------------------------------
gl = gammaln(a);
bs(round((offset+td)/td):end) = A * exp(log(x2).*(a-1) - gl - (x2)./b - log(b)*a);