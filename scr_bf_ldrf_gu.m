function [bs, x] = scr_bf_ldrf_gu(varargin)
% SCR_bf_ldrf_gu  
% Description: 
%
% FORMAT: [bs, x] = scr_bf_ldrf_gu(td, n, offset, p1, p2, p3, p4) 
%     OR: [bs, x] = scr_bf_ldrf_gu([td, n, offset, p1, p2, p3, p4])
%
%   Inputs:
%       td:     time resolution in s
%        n:     duration of the function in s [20s]
%   offset:     offset in s. tells the function where to start with 
%               the response function [0.2s]
%       p1:
%       p2:
%       p3:
%       p4:
%
% REFERENCE
%
%________________________________________________________________________
% PsPM 3.1
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$   
% $Rev$

% initialise
% ------------------------------------------------------------------------
global settings
if isempty(settings), scr_init; end;

% set defaults
% -------------------------------------------------------------------------
p = [0.270885699519043, 2.29354406615360, 1.49589382334256, 0.00402041347274798];
n = 20;
offset = 0.2;

% check input arguments
% -------------------------------------------------------------------------
if nargin==0
    errmsg='No sampling interval stated'; warning('ID:invalid_input', errmsg); return;
elseif nargin == 1
    n_el = numel(varargin{1});
    td = varargin{1}(1);
    if n_el > 1, n = varargin{1}(2); end;
    if n_el > 2, offset = varargin{1}(3); end;
    if n_el > 3, p(1) = varargin{1}(4); end;
    if n_el > 4, p(2) = varargin{1}(5); end;
    if n_el > 5, p(3) = varargin{1}(6); end;
    if n_el > 6, p(4) = varargin{1}(7); end;
elseif nargin > 1
    td = varargin{1};
    n = varargin{2};
    if nargin > 2, offset = varargin{3}; end;
    if nargin > 3, p(1) = varargin{4}; end;
    if nargin > 4, p(2) = varargin{5}; end;
    if nargin > 5, p(3) = varargin{6}; end;
    if nargin > 5, p(4) = varargin{7}; end;
end;

if td > n
    warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
    warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
elseif offset < 0 
    warning('ID:invalid_input', 'Offset has to be a positive number.'); return;
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

% apply gaussian: estimates for smoothed gaussian
% -------------------------------------------------------------------------
sg_gt = exp(-((x2).^2)./(2.*p(1).^2));
sg_ht = exp(-x2*p(2)) + exp (-x2*p(3));
sg_ft = conv(sg_gt, sg_ht);
bs(round((offset+td)/td):end) = p(4) * sg_ft(1:numel(x2));
