function [bs, t] = pspm_bf_spsrf_gamma(varargin)
% pspm_bf_spsrf_box basis 
% 
%   FORMAT: [bf p] = pspm_bf_spsrf_gamma(td,soa,p) OR
%           [bf p] = pspm_bf_spsrf_gamma([td,soa,p])
%           with  td = time resolution in s
%                 p(1) = A
%                 p(2) = x0
%                 p(3) = a
%                 p(4) = b
%          
%________________________________________________________________________
% PsPM 4.0

% initialize
global settings
if isempty(settings), pspm_init; end;

%check input arguments
if nargin==0
    errmsg='No sampling interval stated'; warning('ID:invalid_input', errmsg); return;
elseif nargin == 1
    n_el = numel(varargin{1});
    td = varargin{1}(1);
    if n_el > 1, soa = varargin{1}(2); else , soa=3.5; end;
elseif nargin > 1
    td = varargin{1};
    soa = varargin{2};
    if nargin > 2 
        p = varargin{3};
        errmsg = 'Basis function parameter must be a numeric vector with 4 elements.'
        if ~isnumeric(p) || numel(p)~=4, warning('ID:invalid_input', errmsg); return; end;
    else
        % parameters obtained by fitting a gamma function to smoothed test data
        p = [-0.00953999201164847,-1.90202591900308,10.0912982464000,0.421253777432825];
    end;
end;

A  = p(1);
x0 = p(2);
a  = p(3);
b  = p(4);

% default value
d     = 10;
start = 0;
stop  = d + soa;

if td > (stop-start)
    warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
    warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
elseif soa < 2
    soa = 2;
    stop = d + soa;
    warning('Changing SOA to 2s to avoid implausible values (<2s).');
elseif soa > 8
    warning(['SOA longer than 8s is not recommended. ', ...
        'Use at own risk.']);
end;

shift = soa + x0;

t = (start:td:stop-td)';
bs = A * gampdf(t - shift, a, b);
end

